---
title: "C++时间函数小结"
date: 2016-04-02T20:22:26+08:00
draft: false
tags: ["C++"]
---

最近做大作业要求系统的时间要比正常时间快，于是学习了一下C++时间方面的函数。因为自己用的是Mac队友是Windows，所以专门找的通用的函数的资料。

<!--more-->

## 大作业设计
先记录一下大作业上面我的设计。作业要求软件内的时间（以下称软件时间）要比正常时间（以下称系统时间）快，于是面临的问题有如下几个：

* 如何获得当前系统时间？
* 如何通过计算获得当前软件时间？
* 软件时间从什么时候开始？如果从打开软件时的系统时间开始，关闭软件过五分钟再打开，会面临的软件时间倒退的问题？

于是下面就一个一个来解决这些问题。

## 如何获得系统时间
系统时间有两种表示方式，分别叫做分解时间(broken-down time)和日历时间(Calendar time)。分解时间用如下的数据结构表示：

~~~~C++
#ifndef _TM_DEFINED 
struct tm { 
         int tm_sec;      /* 秒 – 取值区间为[0,59] */ 
         int tm_min;      /* 分 - 取值区间为[0,59] */ 
         int tm_hour;     /* 时 - 取值区间为[0,23] */ 
         int tm_mday;     /* 一个月中的日期 - 取值区间为[1,31] */ 
         int tm_mon;      /* 月份（从一月开始，0代表一月） - 取值区间为[0,11] */ 
         int tm_year;     /* 年份，其值等于实际年份减去1900 */ 
         int tm_wday;     /* 星期 – 取值区间为[0,6]，其中0代表星期天，1代表星期一，以此推 */int tm_yday;     /* 从每年的1月1日开始的天数 – 取值区间为[0,365]，其中0代表1月1日，1代表1月2日，以此类推 */ 
         int tm_isdst;    /* 夏令时标识符，实行夏令时的时候，tm_isdst为正。不实行夏令时的进候，tm_isdst为0；不了解情况时，tm_isdst()为负。*/ 
         }; 
#define _TM_DEFINED 
#endif
~~~~

这是tm结构在time.h中的定义(所以记得包含time.h头文件)。
而日历时间是通过time_t数据类型来表示的，用time_t表示的时间（日历时间）是从一个时间点（例如：1970年1月1日0时0分0秒）到此时的秒数。在time.h中，我们也可以看到time_t是一个长整型数：

~~~~C++
#ifndef _TIME_T_DEFINED 
typedef long time_t;          /* 时间值 */ 
#define _TIME_T_DEFINED       /* 避免重复定义 time_t */ 
#endif 
~~~~

显然，分解时间便于人类观测并获得时间信息（有函数可以以一定时间格式返回tm结构中的时间，接下来会说到），而日历时间可以很方便地计算时间间隔。所以这样看来，问题有解了。

那么如何获得系统当前时间呢？

这就要说到time.h中的几个函数：

~~~~C++
time_t time(time_t * timer);
struct tm * gmtime(const time_t *timer);                                           
struct tm * localtime(const time_t * timer);
~~~~

先说第一个函数。很显然它是用来获取日历时间的。如果你已经声明了参数timer，你可以从参数timer返回现在的日历时间，同时也可以通过返回值返回现在的日历时间，即从一个时间点（例如：1970年1月1日0时0分0秒）到现在此时的秒数。如果参数为空（NULL），函数将只通过返回值返回现在的日历时间，比如下面这个例子用来显示当前的日历时间： 

~~~~C++
#include "time.h" 
#include "stdio.h" 
int main(void) 
{ 
     struct tm *ptr; 
     time_t lt; 
     lt =time(NULL); 
     printf("The Calendar Time now is %d\n",lt); 
     return 0; 
} 
~~~~
运行结果会是一个很大的数字，因为它是一个时间点到现在的秒数。

后两个函数有什么区别呢？

首先要知道这两个函数都是把日历时间转换为分解时间的函数（从`time_t`到`struct tm`）。区别在于，其中`gmtime()`函数是将日历时间转化为世界标准时间（即格林尼治时间），并返回一个tm结构体来保存这个时间，而`localtime()`函数是将日历时间转化为本地时间。比如现在用`gmtime()`函数获得的世界标准时间是2016年04月02日7点18分20秒，那么我用`localtime()`函数在中国地区获得的本地时间会比世界标准时间晚8个小时，即2016年04月02日15点18分20秒。下面是个例子：

~~~~C++
#include <time.h> 
#include <stdio.h> 
int main(void) 
{ 
     struct tm *local; 
     time_t t; 
     t = time(NULL); 
     local = localtime(&t); 
     printf("Local hour is: %d\n",local->tm_hour); 
     local = gmtime(&t); 
     printf("UTC hour is: %d\n",local->tm_hour); 
     return 0; 
} 
~~~~

运行结果是：

~~~~C++
Local hour is: 15 
UTC hour is: 7 
~~~~

## 如何通过计算获得当前软件时间
思路很简单，设计一个函数，每次调用这个函数时，他就能计算软件打开时的系统时间和当前的系统时间之差，然后用软件打开时的软件时间加上这个差乘以时间倍数，所得的结果就应该是当前的软件时间。（其实就是一种天上一天，地下一年的感觉有木有）。然后设计一个类，保存好软件刚开始运行时的系统时间和软件时间，再包括上面说的函数作为一个方法就行了。
所以大致代码如下：

~~~~C++
#define time_factor 5     //时间倍数

class System_Clock {
private:
    time_t init_com_time;
    time_t init_sys_time;
public:
    System_Clock() {
        init_com_time = time(NULL);
        init_sys_time = time(NULL);
    }
    
    struct tm* get_sys_time() {
        time_t cur_com_time = time(NULL); 
        time_t cur_sys_time = init_sys_time + (cur_com_time - init_com_time) * time_factor;
        return localtime(&cur_sys_time);
    }
};
~~~~

其中，`_com_time`指系统时间，`_sys_time`指软件时间。

### 软件时间从什么时候开始
这里主要是为了解决这样一个问题。试想用户用了我们的软件，旅行在系统中已经进行了十个小时，还有一个小时就要到站了好激动，于是关掉软件去吃了个冰淇淋，然后回来打开软件再一看，卧槽为什么我才走了半个小时？

为什么？

因为按上面的方法，再次打开软件时就会再次获得当前系统时间，然后软件时间也是当前系统时间，而现实时间其实只过去了半个小时。。所以，如果每次启动重新更新时间，就会出现旅客行程倒退的问题。

如何解决？

很简单，每次退出程序时保存当前的系统时间和软件时间就好了。这样下一次启动程序时，就先从数据库中读取上一次退出时的系统时间和软件时间，然后同样的道理根据上一次的系统时间和软件时间计算出当前的软件时间作为这次启动的初始软件时间（这次启动的初始系统时间可以一个time函数搞定），这样妈妈就再也不用担心时间回退问题了！

懒得贴代码了。就酱。
