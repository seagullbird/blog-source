---
title: "Headr — An Idea of Mine"
date: 2018-01-11T23:18:28+08:00
draft: false
tags: ["headr", "kubernetes", "cloud", "blog", "container", "docker", "microservice"]
---

Two years ago when I set up my first blog site with [hexo](https://hexo.io/) and deployed it on [Github Pages](https://pages.github.com/), I was so troubled by the contradiction:  The "just enough" features of a static blog site and its various and fantastic collections of themes, against the tedious while geeky write-generate-deploy procedure, which I have to go through everytime I wanna write something new.

<!--more-->

# The Problem

The fact is, when I say "I want to write something", I mean it. Writing is the only thing that I want to do. What I definitely don't want is that:

- I have to open up some terminal windows and type in some "new post" commands, before I can open my markdown editor;
- I have to write some yaml scripts as metadata of the new post before I can actually write something; What's more gross, I have to put this so-called ugly metadata at the beginning of every post!
- I have to `git add . && git commit -m "blablabla" && git push origin master` so that my new post can get published.

And these are just routine stuff I have to do everytime when I **just wanna write something**. I have not yet mentioned the killing process when I firstly downloaded the static blog generator (e.g., hexo), choosing a theme and `git clone`ing it, going through bunches of configurations to get the site satisfied, setting a custom domain, managing goddamn `npm_modules` (still have no idea why I have to learn anything about `npm install` when I just want to write a post), ...

Even though now I transferred from hexo to the faster, simpler static site generator [hugo](https://gohugo.io/), escaped from `npm_modules`, I still have to manage git repositories, write deploy scripts, or use CI tools such as [wercker](http://www.wercker.com/) to maintain the site.

Although painful, there are still reasons for staying this way. 

First of all, static sites load faster, and static files can be cached locally to even accelerate. No database queries on the server side and no intermediate data exchanges.

Secondly, static sites are more secure. You don't have to worry about attacks like sql injection, CSRF and so on.

Last but absolutely not the least, a good static generator usually comes with an abundant collection of well designed themes which are all totally configurable and modifiable. I can always build my unique website out of a gorgeous theme, if I want to write some HTML, CSS or Javascript. What's more exciting, there are always more professional frontend developers creating new themes for the generator. (Check out hugo's themes page).

I choose "static", because I don't want to use those "dynamic" blogging services. Dynamic blogging services, in a word, are still too cumbersome. A static website on the other hand, despite all the crazy developing and maintaining processes, is "just enough" for a personal blog (Or an introduction site; Or a documentaion).

Thus, since the first time I set up my static blog site, I've been think about this: *Is there a way that people can gain all the advantages a static website has to offer, while not doing any geeky operations at all?*

Questing for an answer, I wrote [BLEXT](https://github.com/seagullbird/BLEXT) last year. However, although still basic, BLEXT essentially is a dynamic blogging site provider. And there's no way I can get anyone develop themes for BLEXT since I don't even know how to write the interface for them!

Therefore, the quest is still the unchanged motivation behind **Headr**. **Headr** is the ultimate pusher of my dream: When I want to write something, the only thing I should do is to write something.

# The Solution

Recently with my understanding of new technologies including docker container, cloud and CI/CD gets deeper, I finnally figured out a way to achieve my dream, and it is named **Headr**.

**Headr**, by definition, is a "dynamic" static sites provider. "Dynamic" means people need to register an account for using **Headr**, like they always do when using normal dynamic bloggings. However, the sites **Headr** provides for its users, are all static sites. Each user's site is served by a web server (such as [Nginx](http://nginx.org/) or [Caddy](https://caddyserver.com/)) running in a container, while all the static files of this site are stored in a volume mounted into that container. Static files are maintained by a git server (I'm using [Gitlab](https://about.gitlab.com/)) which, of course, runs in another container with volumes mounted. A typical "add new post" procedure is described like this:

- the new post is pushed to the git server as a `commit` through an API;
- A custom `post-receive` git hook is triggered after the git server received this new `commit`;
- The hook checks out the repo to a temporary directory inside the git server container, and uses hugo to generate the site;
- The site (i.e., a `/public` folder) is generated to a mount point where a volume is mounted, to replace the old `/public` folder;
- While the target volume is also mounted into the web server container, when the `/public` folder (the root of the site) is updated, the web server will serve the new contents when next request comes.

What's important, the whole process can be automated. So all the user does is to open up a client (can be in the browser or a native app; I will inplement both if time permits), write his post, click *Publish*. Next time he refreshes his own website, the new contents are there.

Plus, nice frontend work should be done, so that users can use DOM elements such as checkboxes, select bars to decide the post's metadata, which will be automatically assembled into the post.

Microservices is the architecture I want to choose to inplement the backend just to sharpen my skills. Learning Kubernetes is the very next thing on my to-learn list, so I will try adopting it to maintain all the containers I have to create.

There will be a more specific post discussing the whole system architecture with pictures. This is an "idea" post so let's just keep it the "idea" way.

---

In a word, can't say that I'm not excited having finally something I really want to do again. The first purpose of **Headr** currently isn't making money out of it, but personal learning and growth in the process of realizing it. It would be really fantastic to complete this project.

This is the first post about **Headr** and there will definitely be more. The following one might be a summary about git hooks and the `git subtree` command, both are methods I used in the development of **Headr**.

I just registered **Headr.io** today, hope it will truly help people creating their own blogs in the future.

