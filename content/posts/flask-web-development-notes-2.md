---
title: "《Flask Web开发》读书笔记（二）"
date: 2016-08-19T16:36:35+08:00
draft: false
tags: ["Python", "Flask"]
---

《Flask Web开发》读书笔记（二）：请求－响应循环

<!--more-->

## 程序和请求上下文
Flask从客户端收到请求时，要让视图函数能访问一些对象，这样才能处理请求。**请求对象**就是一个很好的例子，它封装了客户端发送的HTTP请求。
要想让视图函数能够访问请求对象，一个显而易见的方式是将其作为参数传入视图函数，不过这会导致程序中的每个视图函数都增加一个参数。除了访问请求对象，如果视图函数在处理请求时还要访问其他对象，情况会变得更糟。
为了避免大量可有可无的参数把视图函数弄得一团糟，Flask使用**上下文**临时把某些对象变为全局可访问。有了上下文，就可以写出下面的视图函数：
```python
from flask import request
@app.route('/')
def index():    
    user_agent = request.headers.get('User-Agent')  
    return '<p>Your browser is %s</p>' % user_agent 
```
注意在这个视图函数中我们如何把`request`当作全局变量使用。事实上，`request`不可能是全局变量。试想，在多线程服务器中，多个线程同时处理不同客户端发送的不同请求时，每个线程看到的`request`对象必然不同。Flask使用上下文让特定的变量在一个线程中全局可访问，与此同时却不会干扰其他线程。
- - - - -
        在Flask中有两种上下文：**程序上下文**和**请求上下文**。下表列出了这两种上下文提供的变量。
        ![](http://img7.doubanio.com/view/ark_works_pic/common-largeshow/public/582592510.jpg)
        Flask在分发请求之前激活（或推送）程序和请求上下文，请求处理完成后再将其删除。程序上下文被推送后，就可以在线程中使用`current_app`和`g`变量。类似地，请求上下文被推送后，就可以使用`request`和`session`变量。如果使用这些变量时我们没有激活程序上下文或请求上下文，就会导致错误。
```python
>>> from hello import app
>>> from flask import current_app
>>> current_app.name
Traceback (most recent call last):
...
RuntimeError: working outside of application context
>>> app_ctx = app.app_context()
>>> app_ctx.push()
>>> current_app.name
'hello'
>>> app_ctx.pop() 
```
在这个例子中，没激活程序上下文之前就调用`current_app.name`会导致错误，但推送完上下文之后就可以调用了。注意，在程序实例上调用`app.app_context()`可获得一个程序上下文。
## 请求钩子
有时在处理请求之前或之后执行代码会很有用。例如，在请求开始时，我们可能需要创建数据库连接或者认证发起请求的用户。为了避免在每个视图函数中都使用重复的代码，Flask提供了注册通用函数的功能，注册的函数可在请求被分发到视图函数之前或之后调用。
请求钩子使用修饰器实现。Flask支持以下4种钩子。
• `before_first_request`：注册一个函数，在处理第一个请求之前运行。
• `before_request`：注册一个函数，在每次请求之前运行。
• `after_request`：注册一个函数，如果没有未处理的异常抛出，在每次请求之后运行。
• `teardown_request`：注册一个函数，即使有未处理的异常抛出，也在每次请求之后运行。
举个例子：
```python
@auth.before_app_request
def before_request():
    if current_user.is_authenticated() \
            and not current_user.confirmed \
            and request.endpoint[:5] != 'auth.':
            and request.endpoit !='static':
        return redirect(url_for('auth.unconfirmed'))
```
这是一个`before_request`处理程序，它的作用是某一个请求发出后，当函数中三个条件同时满足时，拦截该请求，并重定向到另一个url位置。Flask就不会再执行原请求对应的视图函数。
- - - - -
        在请求钩子函数和视图函数之间共享数据一般使用上下文全局变量`g`。例如，`before_request`处理程序可以从数据库中加载已登录用户，并将其保存到`g.user`中。随后调用视图函数时，视图函数再使用`g.user`获取用户。

## 响应
Flask调用视图函数后，会将其返回值作为响应的内容。大多数情况下，响应就是一个简单的字符串，作为HTML页面回送客户端。
但HTTP协议需要的不仅是作为请求响应的字符串。HTTP响应中一个很重要的部分是**状态码**，Flask默认设为200，这个代码表明请求已经被成功处理。
如果视图函数返回的响应需要使用不同的状态码，那么可以把数字代码作为第二个返回值，添加到响应文本之后。例如，下述视图函数返回一个400状态码，表示请求无效：
```python
@app.route('/')
def index():    
    return '<h1>Bad Request</h1>', 400 
```
视图函数返回的响应还可接受第三个参数，这是一个由首部（header）组成的字典，可以添加到HTTP响应中。
如果不想返回由1个、2个或3个值组成的元组，Flask视图函数还可以返回`Response`对象。`make_response()`函数可接受1个、2个或3个参数（和视图函数的返回值一样），并返回一个`Response`对象。有时我们需要在视图函数中进行这种转换，然后在响应对象上调用各种方法，进一步设置响应。下例创建了一个响应对象，然后设置了cookie：
```python
from flask import make_response
@app.route('/')
def index():    
    response = make_response('<h1>This document carries a cookie!</h1>')    
    response.set_cookie('answer', '42')    
    return response 
```
### 重定向
有一种名为**重定向**的特殊响应类型。这种响应没有页面文档，只告诉浏览器一个新地址用以加载新页面。重定向经常在Web表单中使用。
重定向经常使用302状态码表示，指向的地址由`Location`首部提供。重定向响应可以使用3个值形式的返回值生成，也可在`Response`对象中设定。
不过，由于使用频繁，Flask提供了`redirect()`辅助函数，用于生成这种响应：
```python
from flask import redirect
@app.route('/')
def index():
    return redirect('http://www.example.com') 
```
### abort()处理错误函数
还有一种特殊的响应由`abort()`函数生成，用于处理错误。在下面这个例子中，如果URL中动态参数`id`对应的用户不存在，就返回状态码404：
```python
from flask import abort
@app.route('/user/<id>')
def get_user(id):
    user = load_user(id)
    if not user:
        abort(404)
    return '<h1>Hello, %s</h1>' % user.name 
```
