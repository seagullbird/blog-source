---
title: "Leetcode 542"
date: 2018-05-03T11:56:19+08:00
draft: false
tags: ["Leetcode"]
---

Leetcode 542 : 01 Matrix

<!--more-->

[Address](https://leetcode.com/problems/01-matrix/description/)

# Description

Given a matrix consists of 0 and 1, find the distance of the nearest 0 for each cell.

The distance between two adjacent cells is 1.

**Example 1:** 
Input:

```
0 0 0
0 1 0
0 0 0
```

Output:

```
0 0 0
0 1 0
0 0 0
```

**Example 2:** 
Input:

```
0 0 0
0 1 0
1 1 1
```

Output:

```
0 0 0
0 1 0
1 2 1
```

**Note:**

1. The number of elements of the given matrix will not exceed 10,000.
2. There are at least one 0 in the given matrix.
3. The cells are adjacent in only four directions: up, down, left and right.



# Solution

求最短距离很容易想到 BFS，这道题也确实是 BFS，但是它 BFS 得格外与众不同（至少以我现在的水平看来）。

第一次尝试的方法是：

遍历整个矩阵，找到一个 1 就做一次 BFS，BFS 找到一个 0 之后就算找到了最近的 0，更新结果即可。

这样做结果是 TLE，因为对每个 1 就要做一遍 BFS。

现在来看标答 BFS，只做一遍的 BFS：

```python
class Solution(object):
    def updateMatrix(self, matrix):
        """
        :type matrix: List[List[int]]
        :rtype: List[List[int]]
        """
        # BFS 每加一层，是到 0 的最短距离加 1 的一层
        # 第一层是所有的 0，到 0 的最短距离都是 0
        # 第二层是所有与 0 直接接触的 1，到 0 的最短距离是 1
        # 第三层是所有与 0 只间隔一个 1 的 1，到 0 的最短距离是 2
        # ……
        # 是否能够做完这件事？即是否能够覆盖到所有的 1 并且给它们以正确的距离值？
        # 答：
        # 1. 能否覆盖完全？
        # 每一次找的都是比自己到 0 的距离大的点，
        # 这些点之前不可能找过，因为已经找过的点到 0 的距离都比自己到 0 的距离小，所以不会出现重复找点，
        # 既然不会重复找点，点的数量又是有限值，那一定会找到所有的点；
        # 2. 能否结果正确？
        # 首先确定，第 n 层和第 n-1 层之间到 0 的最短距离只相差 1
        # 所以，第 n 层的结果是否正确完全取决于第 n-1 层的结果是否正确
        # 所以取决于第一层的结果是否正确 => 显然正确
        if not matrix:
            return []
        width = len(matrix[0])
        height = len(matrix)
        dx = [0, 0, 1, -1]
        dy = [1, -1, 0, 0]
        q = [(i, j) for i in xrange(height) for j in xrange(width) if matrix[i][j] == 0]
        res = []
        for i in xrange(height):
            row = []
            for j in xrange(width):
                if matrix[i][j] == 0:
                    row.append(0)
                else:
                    row.append(float('inf'))
            res.append(row)

        
        while q:
            nq = []
            for v in q:
                for k in xrange(4):
                    nx, ny = v[0] + dx[k], v[1] + dy[k]
                    if not (0 <= nx < height and 0 <= ny < width):
                        continue
                    if res[nx][ny] > res[v[0]][v[1]] + 1:
                        res[nx][ny] = res[v[0]][v[1]] + 1
                        nq.append((nx, ny))
            q = nq
        return res
```

嗯解释见注释。。反正我是把自己说服了。