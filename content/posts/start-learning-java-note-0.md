---
title: "来看Java —— 零"
date: 2016-09-19T18:25:27+08:00
draft: false
tags: ["Java"]
---

初学java，重点备忘

<!--more-->

## 第一个Java程序

```java
package learn;

/**
 *
 * @author Seagullbird
 */
public class Learn {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        System.out.println("hello world");
    }
    
}
```

没啥好说的。`Java`里面没有定义在类外面的函数，包括`main`函数。`package`是啥暂时不知道。

### 标准输入输出

顺便在这记一下标准输入输出。输出不说了看上面。

输入用`Scanner`类。

```java
package learn;
import java.util.*;
/**
 *
 * @author Seagullbird
 */
public class Learn {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        Scanner s = new Scanner(System.in);
        int a = s.nextInt();
        System.out.println(a);
    }
    
}

```

具体还是用到的时候看API吧。

## Java import以及Java类的搜索路径

### import

语法为`import package1[.package2…].classname;`

注意：

- import 只能导入包所包含的类，而不能导入包。
- 为方便起见，我们一般不导入单独的类，而是导入包下所有的类，例如`import java.util.*;`

**Java 编译器默认为所有的 Java 程序导入了 JDK 的 java.lang 包中所有的类（import java.lang.*;），其中定义了一些常用类，如 System、String、Object、Math 等，因此我们可以直接使用这些类而不必显式导入。但是使用其他类必须先导入。**

### Java类的搜索路径

反正基本思路一样，先找当前目录再找本地库目录。找不到报错。现在先不写这个。遇到问题再说。

## Java数据类型

基本数据类型和C基本一样。包括：`byte`,`short`,`int`,`long`,`float`,`double`,`char`,`boolean`。其中`byte`占一字节内存。

> 在Java中，整型数据的长度与平台无关，这就解决了软件从一个平台移植到另一个平台时给程序员带来的诸多问题。与此相反，C/C++ 整型数据的长度是与平台相关的，程序员需要针对不同平台选择合适的整型，这就可能导致在64位系统上稳定运行的程序在32位系统上发生整型溢出。

> 八进制有一个前缀 0，例如 010 对应十进制中的 8；十六进制有一个前缀 0x，例如 0xCAFE；从 Java 7 开始，可以使用前缀 0b 来表示二进制数据，例如 0b1001 对应十进制中的 9。同样从 Java 7 开始，可以使用下划线来分隔数字，类似英文数字写法，例如 1_000_000 表示 1,000,000，也就是一百万。下划线只是为了让代码更加易读，编译器会删除这些下划线。

**Java 不支持无符号类型(unsigned)。**

## Java运算符

数学运算符和关系运算符和C一样。补充一下位运算符（其实C也有位运算符，只是我学艺不精）：

位运算符对整数的二进制形式逐位进行逻辑运算，得到一个整数。见下表：


| 运算符  |  说明  |   举例    |
| :--: | :--: | :-----: |
|  &   |  与   |  1 & 4  |
| \|  |  或   | 2 \| 5 |
|  ^   |  异或  |  2 ^ 3  |
|  ~   |  非   |   ~5    |
|  <<  |  左移  | 5 << 3  |
| \>>  |  右移  | 6 >> 1  |

**另外Java也有三目运算符：`condition ? x1 : x2`**

## Java流程控制

与C相同。`if...else`,`for`,`switch case`,`while`等。

## Java数组（静态）

### 基本

> 与C、C++不同，Java在定义数组时并不为数组元素分配内存，因此[ ]中无需指定数组元素的个数，即数组长度。而且对于如上定义的一个数组是不能访问它的任何元素的，我们必须要为它分配内存空间，这时要用到运算符new，其格式如下：

```java
int demeArray[];
demoArray = new int[3];
```

可以在定义的同时分配：

```java
int demoArray[] = new int[3];
```

初始化（静态动态，说白了就是随便你咋个初始化）：

```java
// 静态初始化
// 静态初始化的同时就为数组元素分配空间并赋值
int intArray[] = {1,2,3,4};
String stringArray[] = {"s", "b", "java"};
// 动态初始化
float floatArray[] = new float[3];
floatArray[0] = 1.0f;
floatArray[1] = 132.63f;
floatArray[2] = 100F;
```

### 遍历

除了和C一样的`for`遍历，还有这种：

```java
for( arrayType varName: arrayName ){
    // Some Code
}
```

arrayType 为数组类型（也是数组元素的类型）；varName 是用来保存当前元素的变量，每次循环它的值都会改变；arrayName 为数组名称。

无法使用索引。

### 二维数组

声明和初始化：

```java
int intArray[ ][ ] = { {1,2}, {2,3}, {4,5} };
int a[ ][ ] = new int[2][3];
a[0][0] = 12;
a[0][1] = 34;
// ......
a[1][2] = 93;
```

> Java语言中，由于把二维数组看作是数组的数组，数组空间不是连续分配的，所以不要求二维数组每一维的大小相同。

```java
int intArray[ ][ ] = { {1,2}, {2,3}, {3,4,5} };
int a[ ][ ] = new int[2][ ];
a[0] = new int[3];
a[1] = new int[5];
```

## Java字符串

```java
String str = "strstr";
```

### 一些方法

1. length()：不说。
2. charAt()：相当于python中`List`对象的`index()`，返回字符在字符串中的索引。
3. contains()：子串匹配。
4. replace()：字符串替换，用来替换字符串中所有指定的子串。
5. split()：同python`List`对象的`split()`。以指定字符串作为分隔符，对当前字符串进行分割，分割的结果是一个数组。

## *Java StringBuffer与StringBuider

> String 的值是不可变的，每次对String的操作都会生成新的String对象，不仅效率低，而且耗费大量内存空间。
>
> StringBuffer类和String类一样，也用来表示字符串，但是StringBuffer的内部实现方式和String不同，在进行字符串处理时，不生成新的对象，在内存使用上要优于String。
>
> StringBuffer 默认分配16字节长度的缓冲区，当字符串超过该大小时，会自动增加缓冲区长度，而不是生成新的对象。
>
> StringBuffer不像String，只能通过 new 来创建对象，不支持简写方式。



```java
StringBuffer str1 = new StringBuffer();  // 分配16个字节长度的缓冲区
StringBuffer str2 = =new StringBuffer(512);  // 分配512个字节长度的缓冲区
// 在缓冲区中存放了字符串，并在后面预留了16个字节长度的空缓冲区
StringBuffer str3 = new StringBuffer("str");
```

### StringBuffer类的主要方法

#### append()

```java
StringBuffer str = new StringBuffer(“biancheng100”);
str.append(true);
```

则对象str的值将变成”biancheng100true”。注意是str指向的内容变了，不是str的指向变了。

> 字符串的”+“操作实际上也是先创建一个StringBuffer对象，然后调用append()方法将字符串片段拼接起来，最后调用toString()方法转换为字符串。
>
> 这样看来，String的连接操作就比StringBuffer多出了一些附加操作，效率上必然会打折扣。
>
> 但是，对于长度较小的字符串，”+“操作更加直观，更具可读性，有些时候可以稍微牺牲一下效率。

#### deleteCharAt()

deleteCharAt() 方法用来删除指定位置的字符，并将剩余的字符形成新的字符串。

你也可以通过delete()方法一次性删除多个字符。

```java
StringBuffer str = new StringBuffer("abcdef");
// 删除索引值为1~4之间的字符，包括索引值1，但不包括4
str.delete(1, 4);
```

#### insert()

insert() 用来在指定位置插入字符串。

```java
StringBuffer str = new StringBuffer("abcdef");
str.insert(3, "xyz");
```

最后str所指向的字符串为 abcdxyzef。

#### setCharAt()

setCharAt() 方法用来修改指定位置的字符。

```java
StringBuffer str = new StringBuffer("abcdef");
str.setCharAt(3, 'z');
```

该代码将把索引值为3的字符修改为 z，最后str所指向的字符串为 abczef。

**强烈建议在涉及大量字符串操作时使用StringBuffer。**

### StringBuilder

StringBuilder类和StringBuffer类功能基本相似，方法也差不多，主要区别在于StringBuffer类的方法是多线程安全的，而StringBuilder不是线程安全的，相比而言，StringBuilder类会略微快一点。

### 总结

线程安全：

- StringBuffer：线程安全
- StringBuilder：线程不安全

速度：

一般情况下，速度从快到慢为 StringBuilder > StringBuffer > String，当然这是相对的，不是绝对的。

使用环境：

- 操作少量的数据使用 String；
- 单线程操作大量数据使用 StringBuilder；
- 多线程操作大量数据使用 StringBuffer。
