---
title: "Linux Namespace General"
date: 2017-12-12T22:42:41+08:00
draft: false
tags: ["Linux", "Docker"]
---

《自己动手写 Docker》读书笔记。

<!--more-->

## 1. 概念

### 1.1 Linux Namespace

**Linux Namespace**： 是 kernel 的一个功能，可以隔离一系列的系统资源。

六种不同类型的 Namespace：

| Namespace 类型      | 系统调用参数        |
| ----------------- | ------------- |
| Mount Namespace   | CLONE_NEWNS   |
| UTS Namespace     | CLONE_NEWUTS  |
| IPC Namespace     | CLONE_NEWIPC  |
| PID Namespace     | CLONE_NEWPID  |
| Network Namespace | CLONE_NEWNET  |
| User Namespace    | CLONE_NEWUSER |

### 1.2 clone 与 fork

需要注意的是，clone 与 fork 不是同一个概念。事实上，linux 实现了三种复制进程的系统调用：fork，vfork 和 clone。vfork 此处不表。

我们知道，进程由4个要素组成：

1. 进程控制块：进程标志
2. 进程程序块：可与其他进程共享
3. 进程数据块：进程专属空间，用于存放各种私有数据以及堆栈空间
4. 独立的空间（如果没有4则认为是线程）



fork 创造的子进程复制了父进程的资源，新旧进程使用同一代码段，复制数据段和堆栈段。

*这里的复制，实际上使用了**写时复制（Copy on Write, CoW）** 技术。CoW 也叫隐式共享，是一种对可修改资源实现高效复制的资源管理技术。它的思想是，如果一个资源是可重复的，但没有任何修改（比如刚刚 fork 出来的子进程其资源其实和父进程完全一致），这时并不需要立即创建一个新的资源，这个资源可以被新旧实例（对应这里的子父进程）共享。创建（真正的复制）新资源发生在第一次写操作，也就是资源被修改的时候。*



另一方面，clone 创建子进程的时候则有多种选择，这些选择通过不同的参数指定。

*clone 可以让你有选择性的继承父进程的资源，你可以选择像 vfork 一样和父进程共享一个虚存空间，从而使创造的是线程，你也可以不和父进程共享，你甚至可以选择创造出来的进程和父进程不再是父子关系，而是兄弟关系。*

### 1.3 Example

在调用 `clone()` system call 创建新进程时，传入不同的系统调用参数（或组合），即可使新的进程获得对应的 Namespace。

Golang 示例代码：

```go
package main

import (
    "os/exec"
    "syscall"
    "os"
    "log"
)

func main() {
    cmd := exec.Command("sh")
    cmd.SysProcAttr = &syscall.SysProcAttr{
        Cloneflags: syscall.CLONE_NEWUTS | syscall.CLONE_NEWIPC | syscall.CLONE_NEWPID |
            syscall.CLONE_NEWNS,
    }
    cmd.Stdin = os.Stdin
    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr

    if err := cmd.Run(); err != nil {
        log.Fatal(err)
    }
}

```

main 中 clone 出 `sh` 进程的时候，传入了四个参数的组合，则运行程序启动的 `sh` 进程会获得这四个对应的独立 Namespace。



## 2. UTS Namespace

UTS Namespace 主要用来隔离 nodename 和 domainname 两个系统标识。每个 UTS Namespace 允许有自己的 hostname。

实践提示：

```shell
$ hostname
ubuntu
$ hostname -b bird
$ hostname
bird
```



## 3. IPC Namespace

IPC: Inter-Process Communication。

IPC Namespace 用来隔离 System V IPC 和 POSIX message queues。每个 IPC Namespace 都有自己的  System V IPC 和 POSIX message queue。

[参考1](http://blog.csdn.net/colzer/article/details/8146138)

[参考2](https://stackoverflow.com/questions/4582968/system-v-ipc-vs-posix-ipc)

实践提示：

```shell
$ ipcs -q # 查看现有的 ipc Message Queues

------ Message Queues --------
key        msqid      owner      perms      used-bytes   messages

$ ipcmk -Q # 创建一个 message queue
Message queue id: 0

$ ipcs -q

------ Message Queues --------
key        msqid      owner      perms      used-bytes   messages    
0x8990b7ae 0          root       644        0            0           


$ ipcrm -Q 0x8990b7ae # 删除刚刚创建的 queue
$ ipcs -q

------ Message Queues --------
key        msqid      owner      perms      used-bytes   messages
```



## 4. PID Namespace

隔离进程 PID。



命令：`pstree -pl`

-p：Show PIDs.

-l： Display lone lines.



命令：`echo $$`

显示当前进程 PID。



## 5. Mount Namespace

隔离各个进程看到的挂载点视图。

不同的 Mount Namespace 中的进程，看到的文件系统层次是不一样的。也就是说，在一个隔离的 Mount Namespace 中调用 mount 和 umount 仅会影响该 Namespace 中的文件系统，而不会影响全局（宿主机）中的文件系统。

**注意这里有坑！！！！**

### 5.1 ps -ef 和 /proc

讲坑之前首先要讲这件事。

`ps -ef` 这条命令，可以查看当前的进程。[它的原理](https://unix.stackexchange.com/questions/262177/how-does-the-ps-command-work)，简单来说就是它通过读 /proc 目录下的文件获得进程信息。

> Linux系统上的 /proc 目录是一种文件系统，即 proc 文件系统。与其它常见的文件系统不同的是，/proc 是一种伪文件系统（也即虚拟文件系统），存储的是当前内核运行状态的一系列特殊文件，用户可以通过这些文件查看有关系统硬件及当前正在运行进程的信息，甚至可以通过更改其中某些文件来改变内核的运行状态。 /proc 目录中包含许多以数字命名的子目录，这些数字表示系统当前正在运行进程的进程号，里面包含对应进程相关的多个信息文件。 

所以 `ps -ef` 有效的前提就是这条命令：

`mount -t proc proc /proc`

的执行。注意系统启动时这个就是默认挂载的，所以 `ps -ef` 之前不需要再执行这条命令，除非你又执行了 `umount /proc`。

`man mount`:

> The standard form of the mount command is:
>
> mount -t <u>type</u> <u>device</u> <u>dir</u>
>
> This tells the kernel to attach the filesystem found on <u>device</u> (which is of type <u>type</u>) at the directory <u>dir</u>.  The previous  contents (if any) and owner and mode of <u>dir</u> become invisible, and as long as this filesystem remains mounted, the pathname <u>dir</u> refers to the root of the filesystem on <u>device</u>.

### 5.2 验证 Mount Namespace

有了这些，一个简单的验证 Mount Namespace 的思路就有了：

*用 CLONE_NEWNS 和 CLONE_NEWPID clone 启动一个 sh 进程（稍微修改 1.3 节代码，或者直接执行之），在进程中 `mount -t proc proc /proc`，之后 `ps -ef`。期待的结果应该是只有一个 PID 为 1的 sh 进程，以及执行的 ps -ef 进程。类似于：*

```shell
$ ps -ef 
UID         PID   PPID  C STIME TTY          TIME CMD
root          1      0  0 22:02 pts/0    00:00:00 sh
root          4      1  0 22:02 pts/0    00:00:00 ps -ef
```

而后，在宿主机上启动另外一个 shell，会发现 /proc 的挂载并没有变化，即在宿主机上 `ps -ef` 还是能看到所有的进程。则可以说明在 Mount Namespace 内的 mount 对外部没有造成影响。

### 5.3 坑

如果你在按上面的步骤做验证之前，先执行这条命令 `findmnt -o TARGET,PROPAGATION /proc`，而出现这个输出：

```shell
$ findmnt -o TARGET,PROPAGATION /
TARGET PROPAGATION
/proc  shared
```

那么恭喜，直接按上面步骤做验证就会发现我说的坑。

其效果为，在最后一步，在宿主机上 `ps -ef` 时，你会发现：

```shell
$ ps -ef
Error, do this: mount -t proc proc /proc
```

卧槽！？说好的不会影响宿主机呢？？为什么外面的 /proc 挂载没了！？

显然，这时如果：

```shell
$ ls /proc
```

会发现所有的数字（进程 PID）目录都没有了。（这就是`ps -ef`失效的原因）。

这时你很有可能会：

```shell
$ mount
mount: failed to read mtab: No such file or directory
```

卧槽！？什么情况？



当然，解决办法别人已经告诉你了，

```shell
$ mount -t proc proc /proc
```

就能让梦想还原。

但是这时会有一个发现，重新 `mount | grep proc`，你会发现 proc 被 mount 了两次。（这里是为什么我还不明白，但是重启机器之后就好了。先存个疑吧）

### 5.4 说明

这个问题涉及到了 Mount Namespace 的事件传播机制，linux 中一共定义了四种

- `MS_SHARED`: 同一个 peer group的成员共享 mount 事件
- `MS_PRIVATE`: 私有，不发送，也不接收任何 mount 事件
- `MS_SLAVE`: 介于私有和共享之间。mount group 有一个 master，master 的事件传递到 slave 而 slave 不能传递到 master
- `MS_UNBINDABLE`: 除了不发送和接受 mount 事件之外，这个类型的还不能被 `mount --bind`

而

```shell
$ findmnt -o TARGET,PROPAGATION /
TARGET PROPAGATION
/proc  shared
```

就告诉了我们，/proc 目录就是采用了 shared 传播机制。也就是说，在验证 Mount Namespace 时启动的进程中的 mount 操作被宿主机所接收了，从而覆盖了系统本身的 /proc 目录。而在进程退出之后，仅有的一个 PID 1 目录也被删除，在 /proc 下面就没有了任何 PID 目录。

所以，结论是 `CLONE_NEWNS` 对 `shared` 的挂载表并不能实现隔离。要想正确地验证 Mount Namespace，在执行 5.2 的步骤前，应该先：

```shell
$ mount --make-private /proc
$ findmnt -o TARGET,PROPAGATION /
TARGET PROPAGATION
/proc  private
```

就可以成功验证 Mount Namespace 了。

[参考1](https://woosley.github.io/2017/08/18/mount-namespace-in-golang.html)

[参考2](http://blog.lucode.net/linux/intro-Linux-namespace-4.html)



## 6. User Namespace

User Namespace 主要隔离用户的用户组 ID。也就是说，一个进程的 User ID 和 Group ID 在一个 User Namespace 内外可以是不同的。比较常用的是，在宿主机上以一个非 root 用户运行创建一个 User Namespace，然后在 User Namespace 里面却映射成 root 用户。

实践：

```shell
$ id
uid=0(root) gid=0(root) groups=0(root)
```



## 7. Network Namespace

隔离网络设备，IP 地址等网络相关属性的 Namespace。

实践：

```shell
$ ifconfig
# or
$ ip link
```

