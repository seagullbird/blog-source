---
title: "我来解读一下Leetcode172"
date: 2016-09-15T10:27:44+08:00
draft: false
tags: ["Leetcode"]
---

Leetcode 172 解法备忘

<!--more-->

# Factorial Trailing Zeroes

> Given an integer *n*, return the number of trailing zeroes in *n*!.
>
> **Note: **Your solution should be in logarithmic time complexity.

题目本身很简单，但是主要问题就是，时间复杂度不能超过log(n). 所以花费了大量的思考。

## 思路

- 要求`n!`后面有几个0，即是求`n!`中有多少个10的质因子。

- 10 ＝ 2 ＊ 5，那么如果设`n!`中2的质因子个数为`count2`，5的个数为`count5`，所求即为`min(count2, count5)`，因为一对2和5才能凑成一个10.

- 注意到当指数（设为`m`， `m>0`）相同时，2的m次方是恒小于5的m次方的。说明一个问题：对于任意大于1的n，`n!`中2质因子个数将恒比5质因子的个数多。换句话说，所求即为`count5`.

- 现在问题变成了：在`n!`这个数中，一共有多少个5质因子。

- 考虑到`n! = 1*2*3*4*5*6*7*8*9*10*...*n`，求`n!`中有多少5，就是求从1到n这n个数每个数的5质因子数之和。显然不能被5整除的数是没有5质因子的。

- 画图说明问题：

  ![](/images/leetcode172-1.jpg)

## 代码

```python
class Solution(object):
    def trailingZeroes(self, n):
        """
        :type n: int
        :rtype: int
        """
        # count2 >= count5 constantly
        # focus on count5, result should be equal to count5
        count = 0
        while int(n/5):
            count += int(n/5)
            n = int(n/5)
        return count
```
