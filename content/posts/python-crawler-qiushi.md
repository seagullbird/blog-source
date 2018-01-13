---
title: "Python3 爬虫实战练习 —— 糗事百科"
date: 2016-08-19T14:22:10+08:00
draft: false
tags: ["Python", "crawler"]
---

Python3 爬虫练手实战。简单备忘

<!--more-->

## 需要的库
```python
import urllib
import urllib.request
import re
```
其中re为处理正则表达式需要的库，其余处理HTTP请求。

## 准备url
糗事百科url格式为`http://www.qiushibaike.com/hot/page/ + str(page)`。例如“http://www.qiushibaike.com/hot/page/1”

## 准备headers
只需要添加`user_agent`伪装成浏览器即可。
```python
user_agent = 'Mozilla/4.0 (compatible; MSIE 5.5; Windows NT)'
headers = { 'User-Agent' : user_agent }

```

## 获取到HTML
```python
request = urllib.request.Request(url, headers = headers)
response = urllib.request.urlopen(request)
content = response.read().decode('utf-8')
```
利用已准备好的`headers`和`url`创建http`request`对象，再调用其`urlopen`函数获得http回应，保存在`response`对象里。最后通过`read()`函数及解码（字节流到字符串）将整页html代码以字符串格式保存在`content`变量中。

## 生成正则表达式对象
```python
pattern = re.compile('<h2>(.*?)</h2>.*?<div.*?class="content">(.*?)</div>.*?<i.*?class="number">(.*?)</i>',re.S)
```
`pattern`为一个正则表达式对象，来自于`re.compile()`函数。其中两个参数分别为：用于生成正则表达式对象的正则表达式以及匹配模式。匹配模式取值可以使用按位或运算符’|’表示同时生效，比如re.I | re.M。匹配模式可选值有：
```
 • re.I(全拼：IGNORECASE): 忽略大小写（括号内是完整写法，下同）
 • re.M(全拼：MULTILINE): 多行模式，改变'^'和'$'的行为（参见上图）
 • re.S(全拼：DOTALL): 点任意匹配模式，改变'.'的行为
 • re.L(全拼：LOCALE): 使预定字符类 \w \W \b \B \s \S 取决于当前区域设定
 • re.U(全拼：UNICODE): 使预定字符类 \w \W \b \B \s \S \d \D 取决于unicode定义的字符属性
 • re.X(全拼：VERBOSE): 详细模式。这个模式下正则表达式可以是多行，忽略空白字符，并可以加入注释。
```
## 获得结果
```python
items = re.findall(pattern, content)
for item in items:
    for i in item:
        print(i)
```
`re.findall()`函数以列表形式返回全部能匹配的子串。

## 正则表达式补充说明
1. .\*? 是一个固定的搭配，.和\*代表可以匹配任意无限多个字符，加上？表示使用非贪婪模式进行匹配，也就是我们会尽可能短地做匹配。
2. (.\*?)代表一个分组，在这个正则表达式中我们匹配了五个分组，在后面的遍历item中，item[0]就代表第一个(.\*?)所指代的内容，item[1]就代表第二个(.*?)所指代的内容，以此类推。
3. re.S 标志代表在匹配时为点任意匹配模式，点 . 也可以代表换行符。
