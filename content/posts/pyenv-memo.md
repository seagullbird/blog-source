---
title: "pyenv总结备忘"
date: 2016-09-06T22:04:50+08:00
draft: false
tags: ["Python"]
---

pyenv安装和设置资料总结备忘

<!--more-->

## 安装

Homebrew：

```
$ brew install pyenv
```

或者：

```
$ git clone git://github.com/yyuu/pyenv.git ~/.pyenv
```

后面的`~/.pyenv`是你想安装在硬盘的地址（建议不变）

## 配置

zsh:

```
$ echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
$ echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
$ echo 'eval "$(pyenv init -)"' >> ~/.zshrc
```

或者手动打开`~/.zshrc`在后面加入这三句话：

```
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

bash（未测试）:

```
$ echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
$ echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
$ echo 'eval "$(pyenv init -)"' >> ~/.bashrc
```

之后，重新加载SHELL：

```
$ exec $SHELL -l
```

## 使用

查看现在使用的`python`版本

```
$ pyenv version

```

查看可供pyenv使用的`python`版本

```
$ pyenv versions

```

安装`python`版本

```
$ pyenv install <python版本>
```

安装的版本会在`~/.pyenv/versions`目录下。

对于比较大的版本文件，例如anaconda，可以先到官网下载，然后将文件放在`~/.pyenv/cache`目录下，再执行安装命令时，pyenv不会重复下载。

此外，可以用`--list`参数查看所以可以安装的版本

```
$ pyenv install --list

```

卸载将`install`改为`uninstall`就行

```
$ pyenv uninstall <python版本>

```

设置全局`python`版本，一般不建议改变全局设置

```
$ pyenv global <python版本>

```

设置局部`python`版本

```
$ pyenv local <python版本>

```

设置之后可以在目录内外分别试下`which python`或`python --version`看看效果, 如果没变化的话可以`$ python rehash`之后再试试。

`global` 和 `local` 都是用来切换当前 Python 版本的命令，不过，`global` 是全局切换，`local` 是局部切换。

```
pyenv local 3.5.1

```

通常情况下，我们不适用 `global` 切换命令，因为很多系统工具依赖于低版本的 Python，切换之后，可能会出现不可预知的后果。

## python virtualenv创建纯净虚拟环境

### 安装插件pyenv-virtualenv

pyenv-virtualenv插件安装：项目主页：[https://github.com/yyuu/pyenv-virtualenv](https://github.com/yyuu/pyenv-virtualenv)
pyenv virtualenv是pyenv的插件，为UNIX系统上的Python virtualenvs提供pyenv virtualenv命令。

```
$ git clone https://github.com/yyuu/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
$ echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc
$ source ~/.zshrc
```

注意后两条命令是在使用zsh下。如果是bash将`.zshrc`替换为`.bash_profile`。其余不变。

这个插件将安装在主文件夹下的`.pyenv`文件夹中。（默认隐藏）

### 创建一个2.7.1的虚拟环境

```
pyenv virtualenv 2.7.1 env271
```

再需要创建虚拟环境的文件夹下创建虚拟环境。

这条命令在本机上创建了一个名为env271的python虚拟环境，这个环境的真实目录位于：~/.pyenv/versions/

**注意，命令中的 ‘2.7.1’ 必须是一个安装前面步骤已经安装好的python版本， 否则会出错。**

然后我们可以继续通过 ‘pyenv versions’ 命令来查看当前的虚拟环境。

### 切换和使用新的python虚拟环境：

```
$ pyenv activate env271
```

这样就能切换为这个版本的虚拟环境。通过输入`python`查看现在版本，可以发现处于虚拟环境下了。
下面基本上你就可以在这个虚拟环境里面为所欲为了 :) 再也不用担心系统路径被搞乱的问题了
如果要切换回系统环境， 运行这个命令即可

```
$ pyenv deactivate
```

那如果要删除这个虚拟环境呢？ 答案简单而且粗暴，只要直接删除它所在的目录就好：

```
$ rm -rf ~/.pyenv/versions/env271/
```

或者卸载：

```
$ pyenv uninstall env271
```
