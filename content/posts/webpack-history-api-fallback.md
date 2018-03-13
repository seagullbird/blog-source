---
title: "Webpack History Api Fallback"
date: 2018-03-13T13:09:56+08:00
draft: false
tags: ["Webpack", "Javascript"]
---

There was a little problem when I was writing a Vue.js application. Here's to note it down.

<!--more-->

# Problem

I was using vue-router to create a SPA. My `npm run dev` used to be like this:

```json
{
    ...
    "dev": "webpack-dev-server --open --config webpack.config.js",
    ...
}
```

And here's my `router.js`:

```js
const routers = [
    {
        path: '/list',
        meta: {
            title: '商品列表'
        },
        component: (resolve) => require(['./views/list.vue'], resolve)
    },
    {
        path: '*',
        redirect: '/list'
    }
];

export default routers;

```

Now when I hit `npm run dev` and there runs the server, I could successfully access `localhost:8080` and be redirected to `localhost:8080/list`, everything seemed fine.

However, when I click on *Refresh*, the browser jumps out a `404 not found`.

After rounds of tests, I found that under this circumstance, I could only get to  `localhost:8080/list` by clicking a link on my page, instead of visiting it by directly inputting the URL.

# Solution

The introduction of this webpack middleware [connect-history-api-fallback](https://github.com/bripkens/connect-history-api-fallback) covers all questions and answers:

> Single Page Applications (SPA) typically only utilise one index file that is accessible by web browsers: usually `index.html`. Navigation in the application is then commonly handled using JavaScript with the help of the [HTML5 History API](http://www.w3.org/html/wg/drafts/html/master/single-page.html#the-history-interface). This results in issues when the user hits the refresh button or is directly accessing a page other than the landing page, e.g. `/help` or `/help/online` as the web server bypasses the index file to locate the file at this location. As your application is a SPA, the web server will fail trying to retrieve the file and return a *404 - Not Found* message to the user.
>
> This tiny middleware addresses some of the issues. Specifically, it will change the requested location to the index you specify (default being `/index.html`).

Thus, all I need to do is just add a parameter `--history-api-fallback` to the `dev` command:

```json
{
    ...
    "dev": "webpack-dev-server --open --history-api-fallback --config webpack.config.js",
    ...
}
```

This [blog](http://www.cnblogs.com/vs1435/p/7240178.html) helped, too.

