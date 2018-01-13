---
title: "C++ 11 带来的优雅语法"
date: 2016-03-27T00:17:44+08:00
draft: false
tags: ["C++"]
---

来自微信公众号的内容。记录C++ 11的一些方便用法。

<!--more-->

## 自动类型推导 auto
auto的自动类型推导，用于从初始化表达式中推断出变量的数据类型。通过auto的自动类型推导，可以简化我们的编程工作。
auto是在编译时对变量进行了类型推导，所以不会对程序的运行效率造成不良影响。
另外，似乎auto也并不会影响编译速度，因为编译时本来也要右侧推导然后判断与左侧是否匹配。

```
auto a; // 错误，auto是通过初始化表达式进⾏类型推导，如果没有初始化表达式，就无法确定a
的类型
auto i = 1;
auto d = 1.0;
auto str = "Hello World";
auto ch = 'A';
```

auto对引用的推导默认为值类型，可以指定引用修饰符设置为引用：

```
int x = 5;
int & y = x; 
auot  z = y ;// z 为int
auto & z = y; // z的类型为 int&
```

对指针的推导默认为指针类型，当然，也可以指定*修饰符*（效果一样）：

```
int  *px = &x;
auto py = px;
auto *py = px;
```

推导常量:

```
const int *px = &x;
auto py = px; //py的类型为 const int *
const auto py = px ; //py的类型为const int *
```

## 萃取类型decltype
decltype实际上有点像auto的反函数，使用auto可以用来声明一个指定类型的变量，而decltype可以通过一个变量（或表达式）得到类型。

```
#include <vector>
int main() {
    int x = 5;
    decltype(x) y = x; //等于 auto y = x;
    const std::vector<int> v(1);
    auto a = v[0];        // a has type int
    decltype(v[1]) b = 1; // b has type const int&, the return type of
                          //   std::vector<int>::operator[](size_type) const
    auto c = 0;           // c has type int
    auto d = c;           // d has type int
    decltype(c) e;        // e has type int, the type of the entity named by c
    decltype((c)) f = c;  // f has type int&, because (c) is an lvalue
    decltype(0) g;        // g has type int, because 0 is an rvalue
}
```
有没有联想到STL中的萃取器？写模版时有了这个是不是会方便很多。

## 返回类型后置语法 Trailing return type
C++11支持返回值后置 
例如：

```
int adding_func(int lhs, int rhs);
```

可以写为：

```
auto adding_func(int lhs, int rhs) -> int;
```

auto用于占位符，真正的返回值在后面定义。 
这样的语法用于在编译时返回类型还不确定的场合。
比如有模版的场合中，两个类型相加的最终类型只有运行时才能确定：

```
template<class Lhs, class Rhs>
auto adding_func(const Lhs &lhs, const Rhs &rhs) -> decltype(lhs+rhs) 
{return lhs + rhs;}
cout << adding_func<double,int>(dv,iv) << endl;
```

auto用于占位符，真正的返回值类型在程序运行中，函数返回时才确定。

不用auto占位符，直接使用decltype推导类型：

```
decltype(lhs+rhs) adding_func(const Lhs &lhs, const Rhs &rhs)
```


这样写，编译器无法通过，因为模版参数lhs和rhs在编译期间还未声明； 
当然，这样写可以编译通过：

```
decltype( (*(Lhs*)0) + (*(Rhs*)0) ) adding_func(const Lhs &lhs, const Rhs &rhs)
```

但这种形式实在是不直观，不如auto占位符方式直观易懂。

## 空指针标识nullptr

空指针标识(nullptr)**（其本质是一个内置的常量）**是一个表示空指针的标识，它不是一个整数。这里应该与我们常用的NULL宏相区别，虽然它们都是用来表示空置针，但NULL只是一个定义为常整数0的宏，而nullptr是C++ 11的一个关键字，一个内建的标识符。 
nullptr和任何指针类型以及类成员指针类型的空值之间可以发生隐式类型转换，同样也可以隐式转换为bool型（取值为false）。但是不存在到整型的隐式类型转换。 
有了nullptr，可以解决原来C++中NULL的二义性问题：

```
void F(int a){
    cout<<a<<endl;
}
void F(int *p){
    assert(p != NULL);
    cout<< p <<endl;
}

int main(){
    int *p = nullptr;
    int *q = NULL;
    bool equal = ( p == q ); // equal的值为true，说明p和q都是空指针
    int a = nullptr; // 编译失败，nullptr不能转型为int
    F(0); // 在C++98中编译失败，有二义性；在C++11中调用F（int）
    F(nullptr);

    return 0;
}
```

## 区间迭代 range-based for loop

C++ 11扩展了for的语法，终于支持区间迭代，可以便捷的迭代一个容器的内的元素:

```
int my_array[5] = {1, 2, 3, 4, 5};
// double the value of each element in my_array:
for (int &x : my_array) {
    x *= 2;
}
```
当然，这时候使用auto会更简单:

```
for (auto &x : my_array) {
    x *= 2;
}
```

如果有更为复杂的场景,使用auto的优势立刻体现出来：

```
map<string,int> map;
map.insert<make_pair<>("ss",1);
for(auto &x : my_map)
{
   cout << x.first << "/" << x.second;
}
```

## 非成员begin()和end()
非成员begin()和end()函数。他们是新加入标准库的，除了能提高了代码一致性，还有助于更多地使用泛型编程。它们和所有的STL容器兼容。更重要的是，他们是可重载的。所以它们可以被扩展到支持任何类型。对C类型数组的重载已经包含在标准库中了。

在这个例子中我打印了一个数组然后查找它的第一个偶数元素。如果std::vector被替换成C类型数组。代码可能看起来是这样的：

```
int arr[] = {1,2,3};
std::for_each(&arr[0], &arr[0]+sizeof(arr)/sizeof(arr[0]), [](int n) {std::cout << n << std::endl;});

auto is_odd = [](int n) {return n%2==1;};
auto begin = &arr[0];
auto end = &arr[0]+sizeof(arr)/sizeof(arr[0]);
auto pos = std::find_if(begin, end, is_odd);
if(pos != end)
std::cout << *pos << std::endl;
```

如果使用非成员的begin()和end()来实现，就会是以下这样的：

```
int arr[] = {1,2,3};
std::for_each(std::begin(arr), std::end(arr), [](int n) {std::cout << n << std::endl;});

auto is_odd = [](int n) {return n%2==1;};
auto pos = std::find_if(std::begin(arr), std::end(arr), is_odd);
if(pos != std::end(arr))
std::cout << *pos << std::endl;
```

这基本上和使用std::vecto的代码是完全一样的。这就意味着我们可以写一个泛型函数处理所有支持begin()和end()的类型。

---
**参考**

http://www.stroustrup.com/C++11FAQ.html

https://www.chenlq.net/books/cpp11-faq


**出处**

来自：cnblogs

链接：http://www.cnblogs.com/me115/p/4800777.html

---
注：
文章来自微信公众号“CPP开发者”，侵删。
