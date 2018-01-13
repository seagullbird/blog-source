---
title: "《Flask Web开发》读书笔记（五）"
date: 2016-09-05T17:23:30+08:00
draft: false
tags: ["Python", "Flask"]
---

《Flask Web开发》读书笔记（五）—— 使用Flask_Login登录两种不同用户。

<!--more-->

## 问题描述

问题情境如下：一个网站有两种用户（商家和顾客）需要登录操作。但是由于两种用户所需要保存的数据库内容不一样，所以需要在数据库中实现两个不同的模型（seller和buyer）。由于模型不同，就不能按照书上的方法另建一个Role（角色）模型来处理不同种类用户（如书上的例子：网站管理员和网站使用者）了。如何实现两种用户的登录互不影响，并且App能够正确区分当前登录的是哪种用户呢？



## Flask-Login基础重温

### 准备用于登录的用户模型

要使用Flask-Login，首先要在用户的模型中实现几个方法。（包括`is_authencatied()`, `is_active()`等）。这个步骤可以不用自己实现，在用户模型中继承Flask-login提供的`UserMixin`类就可以。

### 初始化Flask-Login

直接看代码：

**app/__init__.py:**

```python
from flask_login import LoginManager

login_manager = LoginManager()
login_manager.session_protection = 'strong'
login_manager.login_view = 'auth.login'

def create_app(config_name):
    # ...
    login_manager.init_app(app)
    # ... 
```

> `LoginManager`对象的`session_protection`属性可以设为`None`、`'basic'`或`'strong'`，以提供不同的安全等级防止用户会话遭篡改。设为`'strong'`时，Flask-Login会记录客户端IP地址和浏览器的用户代理信息，如果发现异动就登出用户。`login_view`属性设置登录页面的端点。回忆一下，登录路由在蓝本中定义，因此要在前面加上蓝本的名字。

### 加载用户的回调函数

**app/models.py:**

```python
from . import login_manager

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id)) 
```

这个函数对于本问题的解决很关键。先看下文。

## 初次尝试 

最开始我是直接写了两个不同的用户模型，初始化了一个`login_manager`，并在`models.py`中实现了一个回调函数。该回调函数我返回的是`Seller.query.get(int(user_id))`。然后我尝试运行，发现用商户帐号登录商户页面时完全没有问题，但是用顾客帐号在顾客登录页面登录时，重定向会把我重定向到商户界面。打印`current_user`变量也发现他变成了`id`值与我所登录的顾客相同的商户账户。（一个可以料到的错误结果）

很显然，问题就出在这个回调函数上，因为我根本没有用它来返回过任何有关顾客模型即`Buyer`的信息。但是由于这只是一个回调函数， 我直接在这个函数里面进行改动肯定是行不通的，因为我都不知道它到底是在哪儿调用，参数是怎么传进来的。

我想到的第一个办法，是初始化两个`login_manager`。由于该回调函数使用了`login_manager`中定义的`user_loader`装饰器，我猜想如果用两个`login_manager`来一个负责商户用户的登录，一个负责顾客用户的登录，并定义两个不同的装饰器，是不是就可以解决了问题。

------

事实证明是不行的。实际上，我现在认为在一个`app`中同时定义两个`Login_Manager()`类对象本身就是一个错误的做法（这句话存疑，不对这句话负责）。

总之，当我是用两个`login_manager`对象和用两个`login_manager.user_loader`装饰的回调函数时，情况并没有比之前的情况好一点点。

于是，我决定还是回归一个`login_manager`，重新想办法从回调函数的调用处来解决问题。

**（有句话可能没说清楚，我在两个用户模型中都定义了一个`role`对象用来保存该用户模型的类型。按道理来讲的话，由于回调函数只是收到了一个用户id的参数，并没有收到关于用户类型的任何信息，所以才会有上述错误。然而我并不知道这个回调函数如何工作，所以没法自己修改它的参数。）**

## 一个测试

很显然，在用户填写好正确的登录信息并点击登录后，视图函数会调用Flask_Login的自带方法`login_user()`来登录用户，并将`current_user`变量从匿名用户对象更新为新建的用户对象。在之前的用户登录视图函数中我这样写：

```python
if form.validate_on_submit():
        user = Buyer.query.filter_by(username=form.username.data).first()
        if user is not None and user.verify_password(form.password.data):
            login_user(user, form.remember_me.data)
            flash('Welcome')
            return redirect(url_for('buyer.user_init'))
```

如果我在`login_user()`函数执行后的下一行打印`current_user`，我将正确地等到一个`Buyer`类型的对象。但是，当重定向完成，我在重定向后的视图函数（在这里即`buyer.user_init`）的第一行打印`current_user`变量时，我就会得到一个错误的`Seller`对象。但是它的`id`值一定和刚刚打印的`Buyer`对象完全一致。

这说明，上文中的回调函数就是在重定向这个过程中起了作用。因为它根据传入的`user_id`参数返回了一个`id=user_id`的`Seller`对象。

## 是时候看看源码了

为什么会有这个回调函数？我觉得我自己说不清楚。就先粘贴一段网上查到的评论吧：

> 在重载用户对象的时候reload_user方法会调用user_callback，至于为什么要载用户对象，拿那是user_id存在session中，不用重复登录。

我理解的大概意思就是，每次URL发生变化时，Flask-Login会只将当前的用户`id`存放在`session`中，之后再从`session`中获得这个id，并传给开发者提供的回调函数来再次获得当前已登录的对象。

再粘贴一段源码：

```python
def user_loader(self, callback):
        '''
        This sets the callback for reloading a user from the session. The
        function you set should take a user ID (a ``unicode``) and return a
        user object, or ``None`` if the user does not exist.

        :param callback: The callback for retrieving a user object.
        :type callback: callable
        '''
        self.user_callback = callback
        return callback
```

如你所见，这就是用来装饰回调函数的`user_loader`函数。它将`login_manager()`自身的`user_callback`函数设置为开发者提供的回调函数，并将在下面这个`reload_user`函数中调用它：

```python
    def reload_user(self, user=None):
        ctx = _request_ctx_stack.top

        if user is None:
            user_id = session.get('user_id')
            if user_id is None:
                ctx.user = self.anonymous_user()
            else:
                if self.user_callback is None:
                    raise Exception(
                        "No user_loader has been installed for this "
                        "LoginManager. Add one with the "
                        "'LoginManager.user_loader' decorator.")
                user = self.user_callback(user_id)
                if user is None:
                    ctx.user = self.anonymous_user()
                else:
                    ctx.user = user
        else:
            ctx.user = user
```

很显然，这里就是开发者设置的回调函数被调用的地方。回调函数返回什么类型的对象，这里的`user`对象就会被赋值为什么对象，下一次加载时`current_user`也就会被赋值成什么对象。

另外可以看到，这个`reload_user`函数是从`session`中获得的`user_id`。所以，**如果我们每次登录时，把用户对象的`role`值也保存在`session`中，并在这里从`session`中获得该值并传入回调函数，就可以在回调函数中通过`role`值来判断，进而返回正确的用户模型了。最后不要忘了在`logout()`的时候清空`session`就好。**

于是我们在源码中增加一点东西如下：

```python
    def reload_user(self, user=None):
        ctx = _request_ctx_stack.top

        if user is None:
            user_id = session.get('user_id')
            role = session.get('role')
            if user_id is None or role is None:
                ctx.user = self.anonymous_user()
            else:
                if self.user_callback is None:
                    raise Exception(
                        "No user_loader has been installed for this "
                        "LoginManager. Add one with the "
                        "'LoginManager.user_loader' decorator.")
                user = self.user_callback(user_id, role)
                if user is None:
                    ctx.user = self.anonymous_user()
                else:
                    ctx.user = user
        else:
            ctx.user = user
```

在回调函数中：

```python
@login_manager.user_loader
def load_seller(user_id, role):
    if role == 'seller':
        return Seller.query.get(int(user_id))
    else:
        return Buyer.query.get(int(user_id))
```

在视图函数中：

```python
if form.validate_on_submit():
        user = Buyer.query.filter_by(username=form.username.data).first()
        if user is not None and user.verify_password(form.password.data):
            login_user(user, form.remember_me.data)
            session['role'] = user.role
            flash('Welcome')
            return redirect(url_for('buyer.user_init'))
```

再说一遍，记得在`logout()`时清空`session`.就不再贴代码了。
