---
title: "Go Code Auto Format"
date: 2018-02-14T14:55:42+08:00
draft: false
tags: ["Go"]
---

Method to auto format your go code.

<!--more-->

> I really like Go’s commitment to a standard code format, but I constantly forget to format my files!

# gofmt

`gofmt` is the tool for formatting go code. Usually, I would run:

```shell
$ gofmt -w <file>
```

to format a `*.go` file.

Also, you can run:

```shell
$ gofmt -w
```

in a project directory, this will exanmine all codes in the directory and format all of them.

This brings up a problem, which is the `vendor` folder. Normally we would not want to format codes in the `vendor` directory, because those codes are not written by ourselves, plus they're always under version control.

So to ignore the `vendor` folder:

```shell
$ gofmt -w -l $(find . -type f -name '*.go' -not -path "./vendor/*")
```

# git pre-commit hook

Now I will never want to manually run this command every time I want to commit some codes. In fact, I don't want to run any command just to format my code. This should definitely be an automated job.

Git has a commonly under-utilized feature: [hooks](http://git-scm.com/book/en/Customizing-Git-Git-Hooks). You can think of a hook as an event that gets triggered before and after various stages of revision control process. Some hooks of note are:

- `prepare-commit-msg` - Fires before the commit message prompt.
- `pre-commit` - Fires before a `git commit`.
- `post-commit` - Fires after a `git commit`.
- `post-checkout` - Fires after changing branches.
- `post-merge` - Fires after merging branches.
- `pre-push` - Fires before code is pushed to a remote.

To automate our formatting job, all we need to do is to write some `pre-commit` script code.

Suppose now I have a local git golang repository named my-go-project. Here's what we do:

```shell
$ cd path/to/my-go-project/.git/hooks
$ touch pre-commit
$ chmod +x pre-commit
$ vim pre-commit
```

and write:

```bash
echo "\033[0;32mFormatted code files:\033[0m"
gofmt -w -l $(find . -type f -name '*.go' -not -path "./vendor/*")
git add .
```

And that's it.

from now on every time we commit some codes in my-go-project, this script will be executed, format our code and add the formatted version of codes all for that commit we triggered.

