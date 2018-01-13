---
title: "Tricks Learned in Codewars [Python]"
date: 2016-09-29T21:02:47+08:00
draft: false
tags: ["Python", "Codewars"]
---

Tricks learned in CodeWars —— Python

<!--more-->

## A string's reverse

How to reverse a string as quickly as possible?

The answer is `[::-1]`.

**Example:**

```python
>>> string = '1234567890'
>>> string[::-1]
'0987654321'
```

## Prefill an Array

Prefill an Array with a fixed value **without loop.**

```python
def prefill(n,v=None):
    try:
        return [v]*int(n)
    except Exception as e:
        raise TypeError('%s is invalid' % n)
```

### True without return 

This is easy.

```python
solve = lambda : True
```



Waiting for new stuff...