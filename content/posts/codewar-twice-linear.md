---
title: "CodeWars Kata -- Twice Linear"
date: 2016-09-29T20:52:11+08:00
draft: false
tags: ["Python", "Codewars"]
---

CodeWars Kata —— Twice Linear

<!--more-->

> **Description**:
>
> Consider a sequence `u` where u is defined as follows:
>
> 1. The number `u(0) = 1` is the first one in `u`.
> 2. For each `x` in `u`, then `y = 2 * x + 1` and `z = 3 * x + 1` must be in `u` too.
> 3. There are no other numbers in `u`.
>
> Ex: `u = [1, 3, 4, 7, 9, 10, 13, 15, 19, 21, 22, 27, ...]`
>
> 1 gives 3 and 4, then 3 gives 7 and 10, 4 gives 9 and 13, then 7 gives 15 and 22 and so on...
>
> **Task**:
>
> Given parameter `n` the function `dbl_linear` (or dblLinear...) returns the element `u(n)` of the ordered (with <) sequence `u`.
>
> **Example**:
>
> `dbl_linear(10) should return 22`
>
> **Note:**
>
> Focus attention on efficiency

This kata is only `5kyu` however costs me days.

My finnal solution:

```python
def dbl_linear(n): 
    u = [1]

    def isInU(q):
        low = 0
        high = len(u)-1
        while low <= high:
            mid = int((low+high)/2)
            if u[mid] == q: return True
            if u[mid] > q: high = mid-1
            else: low = mid+1
        if q > u[mid]: return False, mid + 1
        elif q < u[mid]: return False, mid
        else: print('sth. wrong')
    
    for index, num in enumerate(u):
        jx = isInU(2*num+1)
        if jx != True:
            u.insert(jx[1], 2*num+1)
        jy = isInU(3*num+1)
        if jy != True:
            u.insert(jy[1], 3*num+1)
        if index == int(n*3/5):
            break
    
    return u[n]
```

The key point was that `3/5`。Be more that `3/5` will only result in Timeout. But this number was only gained through tests but not provements. It is a shame.

The author of this kata provide a solution from which I learned a lot. 

```python
from collections import deque

def dbl_linear(n):
    h = 1; cnt = 0; q2, q3 = deque([]), deque([])
    while True:
        if (cnt >= n):
            return h
        q2.append(2 * h + 1)
        q3.append(3 * h + 1)
        h = min(q2[0], q3[0])
        if h == q2[0]: h = q2.popleft()
        if h == q3[0]: h = q3.popleft()
        cnt += 1
```

Two `deques` guarantee that `h` comes out in order. 
