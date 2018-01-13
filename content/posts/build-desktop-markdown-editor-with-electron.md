---
title: "Build Desktop Markdown Editor With Electron"
date: 2016-11-05T17:39:06+08:00
draft: false
tags: ["Javascript", "Electron"]
---

My building process of a desktop markdown editor based on Electron.

<!--more-->

## Requirements

- node.js / npm

- [Electron](https://github.com/electron/electron)

- [Marked](https://github.com/chjj/marked)

- [Bootstrap-Markdown](http://www.codingdrama.com/bootstrap-markdown/)

## Initiation

I won't start with a completely empty file since it's too time-wasting. Let's start with the `electron-quick-start` repo which gave me the very basic structure of Electron and all the necessary node dependencies installed including the `electron-prebuilt` which is the heart of any electron app and the starts the very app itself!

```zsh
$ git clone https://github.com/electron/electron-quick-start
$ mv electron-quick-start myMDE
$ cd myMDE
$ npm install
$ npm start
```

Notice: I have put `bootstrap.min.css` in `myMDE/css/`  in advance.

## Preparation

Download `marked.min.js`, `jquery.min.js`, `bootstrap.min.js` and `bootstrap-markdown.js` (I presume you know where to find them) and put them in folder `/js/`.

Download `bootstrap-markdown.min.css` and `bootstrap.min.css` in `/css/` folder.

**Following is important:**

Add

```javascript
if (typeof module === 'object') {window.module = module; module = undefined;}
```

to the top of `jquery.min.js`,

and

```javascript
if (window.module) module = window.module;
```

to the bottom.

**This must be done otherwise jQuery won't run properly on the program.**

## Create front page

**myMDE/index.html:**

```html
<!DOCTYPE html>
<html>
<head>
    <title>myMDE</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
    <link href="css/bootstrap-markdown.min.css" rel="stylesheet">
</head>

<body>

    <textarea name="plainText" id="plainText" placeholder="Write your Markdown content here"></textarea>

    <!-- <script src="js/app.js"></script> -->
    <script src="js/jquery.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/marked.min.js"></script>
    <script src="js/bootstrap-markdown.js"></script>
    <script src="https://use.fontawesome.com/ab291d07ba.js"></script>
    <script>
        window.onload = function() {
        $("#plainText").markdown({autofocus:true});
        }
    </script>
</body>
</html>
```

Only one `textarea`, and Bootstrap-Markdown will do the rest.

**myMDE/css/style.css:**

```css
html, body, body>div, textarea {
    height: 100%;
    width: 100%;
}
```

Only to make a full screen.

And so far we've built an editor with preview mode.

![1_1](/images/build-desktop-markdown-editor-with-electron-1_1.png)

Next we are gonna add Open\Save functions to it.

TO BE CONTINUED...
