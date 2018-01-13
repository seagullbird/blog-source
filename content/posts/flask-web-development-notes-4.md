---
title: "《Flask Web开发》读书笔记（四）"
date: 2016-08-19T18:09:33+08:00
draft: false
tags: ["Python", "Flask"]
---

《Flask Web开发》读书笔记（四）：再议动态增加表单问题

<!--more-->

上一篇后半部分提出了一个实际问题，即：
**在一个网页上，默认只有一个表单，但是点击一个按钮可以增加一张同样的表单，（表单数大于一张时点击另一个按钮可以减少一张表单），在我还不会javascript的前提下，我该如何实现。**
上一篇重点说明了利用`FieldList`和`FormField`进行动态增加表单的准备思路，但是如何在视图函数中处理和在模版中实现并没有具体说明。在基础表单类一样的前提下，这一篇重点来说明这一方面问题，并为这个大问题提出一个尽量完美的解决办法。
## 纠错
上一篇最后说到，点击增加和删除只能使用重定向，所以已填内容不能被保存。然后又想到是否可以存进`session`来进行保存。这是我写上一篇文章的时候才想到的办法， 但后来证明并不实用。因为重定向之后请求已经结束，原先的表单对象已经被释放，原先的表单也会恢复到初始大小。所以如果要用`session`来存，不仅要存原始数据， 还要存原始大小，以及代表增加或删除的变量。这样做我试过， 但是遇到了现在已经想不起来的bug，所以不再考虑。
## 再看request
 已经知道，“Flask从客户端收到请求时，要让视图函数能访问一些对象，这样才能处理请求。**请求对象**就是一个很好的例子，它封装了客户端发送的HTTP请求。”（——《读书笔记（二）》）。在上下文环境中，Flask提供一个`request`对象可供全局访问，这就是所谓的**请求对象**。这个对象包括了所有HTTP请求的参数。其中有一个参数，这里会用到。
**request.form**
`form`参数的官方解释是：
> A **MultiDict** with the parsed form data from POST or PUT requests. Please keep in mind that file uploads will not end up here, but instead in the **files** attribute.

对于`MultiDict`结构，要注意它来自于`werkzeug.datastructures`（并非Python原生数据结构之一），同样把它的注释粘贴如下：
>  A **MultiDict** is a dictionary subclass customized to deal with **multiple values for the same key** which is for example used by the parsing functions in the wrappers. This is necessary because some HTML form elements pass multiple values for the same key.

简单来说就是一个支持键值一对多的数据结构。看例子：
```python
>>> d = MultiDict([('a', 'b'), ('a', 'c')])
>>> d
MultiDict([('a', 'b'), ('a', 'c')])
>>> d['a']
'b'
>>> d.getlist('a')
['b', 'c']
>>> 'a' in d
True
```
很容易明白。回到之前的话题，`request`对象的`form`参数包含了哪些数据呢？打印出来就能看到。
```python
ImmutableMultiDict([('csrf_token', '1471712099##3b18c265a673658633393f26ce89031bc6211063'), ('dmform-1-man', '500'), ('dmform-0-man', '100'), ('dmform-1-jian', '50'), ('dmform-0-jian', '20'), ('submit', '提交')])
```
这是我填完表点了提交按钮之后，视图函数中打印出来的`request.form`对象的内容。注意到两点：
1. 访问`form['submit']`可以获取到发起本次提交的按钮名称；
2. 提交的表单中的具体数据内容（每个字段的输入）也存在于`form`结构中。
3. 除了上述两个主要内容外，只剩下键名为`csrf_token`的元素。

于是，我们可以得到的信息有：

1. 通过计算完全可以得到这次提交时页面上有多少字段。（`len()`函数可以返回`MultiDict`对象中不同的键名个数，由于`form`参数中每个键名都不同，等价于返回其中元素的总个数。用这个数字减去名为`'submit'`和`'csrd_token'`的两对值，即页面上所有字段数目。再除以每个表单中的字段数目（在这里是2），即可得到表单数。）
2. 发起本次提交的按钮究竟是哪个。换句话说，我们可以知道用户到底是点了`增加表单`、`减少表单`还是整个表单的`提交`键。

## 代码实现
**../views.py:**
```python
#视图函数中
@main.route('***')
def index():
    #...
    form = FatherForm()
    # 获取提交类型(按的哪个按钮)
    submit_type = request.form.get('submit')
    
    if submit_type == '增加表单' or submit_type == '减少表单':
       if submit_type == '增加表单':
            form.add_form()
            elif submit_type == '减少表单':
            form.del_form()
        return render_template('shop_admin.html', form=form, page=2, dm=dm) 
            # 并没有选择重定向，请求未结束，所以表格中数据不会丢失，故而也不用还原表格（表格还是原来的表格，不是新申请的表格）
        
    if form.validate_on_submit():
        #...
        return redirect(url_for('main.index'))
    return render_template('...', form=form)
```
而在模版中，`增加表单`和`减少表单`两个按钮只用简单的`submit`类型的按钮就可以。这样发出的HTTP请求method为`POST`。
```html
<input class="btn btn-default" id="submit" name="submit" type="submit" value="增加规则">
<input class="btn btn-default" id="submit" name="submit" type="submit" value="减少规则">
```
## 解释
程序第一次或者重定向到该URL时，首先会创建父表单类对象`form`（非`request`里面那个`form`参数）。然后从`request`的`form`参数中获取提交类型。（如果不能获取得到说明不是`POST`请求）。获取后进行判断，如果用户点击的是增加或删除按钮，则在将`form`对象更新后，重新渲染表单。（相当于拦截， 即不执行对表单的验证过程）。如果不是，那么用户点击的正常`提交`按钮，则按照一般步骤进行验证并处理数据。
## 注意
`return render_template()`的时候，**form对象不会被刷新**！因为这个时候请求未结束，所以表格中数据不会丢失，故而也不用还原表格（表格还是原来的表格，不是新申请的表格）。如果是重定向到这个URL，那么会创建新的`form`对象，原有的数据和尺寸也就丢失了。所以，在响应增加和删除表单这两种方式时，我们选择了返回（`return`）`render_template()`而不是`redirect()`。
## 总结
至此我已经在不使用任何前端代码的情况下，为这个问题提供了一个相对完美和完善的解决方案。虽然还是很向往不用刷新页面就能动态生成网页元素的实现方法， 但由于精力有限， 这里就不再深入研究了。这个方法目前唯一的不足就是每次点击“增加”或“删除”都会有一个刷新的过程（但已填数据不会丢失），在网速正常稳定的条件下， 能达到的用户体验已经与前端脚本能写出来的效果相差无几了。也就暂时告一段落。
