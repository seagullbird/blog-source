---
title: "《Flask Web开发》读书笔记（三）"
date: 2016-08-19T17:09:33+08:00
draft: false
tags: ["Python", "Flask"]
---

《Flask Web开发》读书笔记（三）：Web表单，Flask-WTF和Flask-Bootstrap WTforms support

<!--more-->

## 最简单的流程
### 在 forms.py 中定义表单类：
```python
from flask_wtf import Form
from wtforms import StringField, SubmitField
from wtforms.validators import Required

class NameForm(Form):
    name = StringField('What is your name?', validators=[Required()])
    submit = SubmitField('Submit') 
```
可以看到：
1. 表单类继承自`flask_wtf`包中的`Form`类；
2. 各种`Field`都来自`wtforms`；
3. 各种验证函数来自`wtforms.validators`。
### 在视图函数中建立表单实例并准备渲染
**../views.py:**
```python
from flask import render_template
from .forms import NameForm

@app.route('/', methods=['GET', 'POST'])
def index():
    name = None
    form = NameForm()
    if form.validate_on_submit():
        name = form.name.data
        form.name.data = ''
    return render_template('index.html', form=form, name=name) 
```
请求类型为`GET`情况下， 视图函数创建表单实例，并通过`render_template()`函数将其传递给html模版进行渲染。
### 把表单渲染成HTML
表单字段是可调用的，在模板中调用后会渲染成HTML。刚刚视图函数把一个`NameForm`实例通过参数`form`传入模板，在模板中可以生成一个简单的表单，如下所示：
```html
<form method="POST">
  {{form.hidden_tag()}}
  {{ form.name.label }} {{ form.name() }}
  {{ form.submit() }}
</form> 
```
可以看出这样写工程量很大。而Flask-Bootstrap提供了一个非常高端的辅助函数，可以使用Bootstrap中预先定义好的表单样式渲染整个Flask-WTF表单，而这些操作只需一次调用即可完成。使用Flask-Bootstrap，上述表单可使用下面的方式渲染：
```html
{% import "bootstrap/wtf.html" as wtf %}
{{ wtf.quick_form(form) }} 
```
`import`指令的使用方法和普通Python代码一样，允许导入模板中的元素并用在多个模板中。导入的bootstrap/wtf.html文件中定义了一个使用Bootstrap渲染Falsk-WTF表单对象的辅助函数。`wtf.quick_form()`函数的参数为Flask-WTF表单对象，使用Bootstrap的默认样式渲染传入的表单。
- - - - -
        以上即为显示一张表单的最简单的方式。通过定义表单类，创建表单实例并传入模版，在模版中使用`Flask-Bootstrap`提供的`wtf.quick_form()`函数直接渲染一整张表单。但是，问题往往不会这样简单。
## 一个实际问题
如果我想实现：在一个网页上，默认只有一个表单，但是点击一个按钮可以增加一张同样的表单，（表单数大于一张时点击另一个按钮可以减少一张表单），在我还不会javascript的前提下，我该如何实现。
## FieldList和FormField
`FieldList`也是WTForms支持的HTML标准字段之一，但它可以被看作由一组指定类型的字段组成的集合。并且可以通过`append_entry()`和`pop_entry()`函数增加或删除一个`FieldList`实例中的指定类型字段。
而`FormField`是一个包含整张表单的字段。将它写进一个表单类，可以理解为把表单作为字段嵌入另一个表单。
连起来理解就是，要达到上一节说的目的，一个想法是首先创建单独一个表单的子表单类，然后将这个子表单类通过`FormField`作为`FormField`字段类型初始化一个`FieldList`实例，创建只包含该实例和提交字段的父表单类，然后就可以通过`FieldList`类包含的`append_entry()`和`pop_entry()`函数来实现表单的增加和删除了。
**../forms.py:**
```python
from flask_wtf import Form
from wtforms import FieldList, FormField, SubmitField

# 子表单类
class SonForm(Form):
    # Fields of one single form (without SubmitField)

# 父表单类    
class FatherForm(Form):
    forms = FormList(FormField(SonForm), label='', min_entries=1) #min_entries参数指明该FormList最少应包含的字段数，此处即至少1个FormField类型字段
    submit = SubmitField('Submit')
    def add_form(self):
        self.forms.append_entry()
        
    def del_form(self):
        self.forms.pop_entry()
```
**../views.py:**
```python
#视图函数中
@main.route('***')
def index():
    #...
    form = FatherForm()
    #...
    return render_template('...', form=form)
```
## 要注意的问题和bug
### wtf.quick_form()失效
注意，视图函数应该创建的表单实例是父表单类而不是子表单类，因为是父表单类包含所有子表单类，也只有父表单类具有增加和删除子表单类的功能。
然而这样将实例传入模版后，发现Flask-Bootstrap的`wtf.quick_form()`函数无法完成对包含`FieldList`字段的表单进行正确的渲染。要想正常显示表单，只能通过遍历`FieldList`字段中的元素（幸好`FieldList`是可遍历的）——每一个`FormField`字段，对于每一个`FormField`字段（实际为一张完整的表单）再调用Flask-Bootstrap提供的`wtf.form_field()`函数渲染其中每一个字段。
```html
{% for forms in form.dmform %}
    {% for field in forms %}
        {{ wtf.form_field(field) }}
    {% endfor %}
    {% endfor %}
```
这当中，`form`对象为视图函数传入的父表单类实例，`dmform`则是父表单类中的`FieldList`对象。
### 子表单类不能再从Form继承
准确地说，是不能再从`from flask_wtf import`的`Form`继承。而是应该从`wtforms`中的`Form`继承。（都叫`Form`，但是来源不同。注意上面的代码是错的，子表单类还是继承的来自`flask_wtf`的`Form`）。所以应该改为：
```python
from wtforms import Form as NoCsrfForm

# 子表单类
class SonForm(NoCsrfForm):
    # Fields of one single form (without SubmitField)
```
至于为什么，我也还说不清楚。这个问题的解决方式是从Stack OverFlow上面一个问题中抄来的。也许你能从`Form`的别名`NoCsrfForm`看出端倪？
### 增加和删除只能重定向（目前限于知识水平）
这意味着，点击增加或删除会刷新整个页面，之前填的内容都不能被保存（写博文的时候突然想起来，其实可以保存在用户会话中，以后再尝试吧，现在不写了）。无论如何，刷新页面是免不了的。所以还要在视图函数中实现增添判断和调用父表单类实例的增减表单函数。

---

总结，至少这个问题的不完美解决让我对flask+wtf+flask-bootstrap的套路有了更深入的了解。另外也学到了书上没讲的`FieldList`和`FormField`的结合使用法。
