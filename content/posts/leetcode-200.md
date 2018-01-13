---
title: "我来解读一下Leetcode200"
date: 2016-09-22T16:26:54+08:00
draft: false
tags: ["Leetcode"]
---

Leetcode 200 : Numbers of Islands

<!--more-->

> Given a 2d grid map of `'1'`s (land) and `'0'`s (water), count the number of islands. An island is surrounded by water and is formed by connecting adjacent lands horizontally or vertically. You may assume all four edges of the grid are all surrounded by water.
>
> **\*Example 1:***
>
> ```
> 11110
> 11010
> 11000
> 00000
> ```
>
> Answer: 1
>
> **\*Example 2:***
>
> ```
> 11000
> 11000
> 00100
> 00011
> ```
>
> Answer: 3

简单一句话说，数一个二维矩阵中`'1'`连成的块的个数。

解法说白了就是遍历整个矩阵然后深搜（或者宽搜）遇到的没有访问过的`'1'`，将没有访问过的`'1'`标记为已访问过的。一次搜索就搜完一个块，搜索的次数就是块的总个数。

我写的解法是宽搜，算法我觉得理论上讲是没有问题的，但是超时了。我先把我写的贴上来。

```python
class Solution(object):
    def numIslands(self, grid):
        """
        :type grid: List[List[str]]
        :rtype: int
        """
        # BFS
        if not grid:
            return 0
        count = 0
        covered = [[0 for i in range(len(grid[0]))] for i in range(len(grid))]
        # x for col(0~len(grid[0])-1), y for row(0~len(grid)-1)
        index = [(x, y) for x in range(len(grid[0])) for y in range(len(grid))]
        for curIndex in index:
            bfsQue = []
            if grid[curIndex[1]][curIndex[0]] == '1' and not covered[curIndex[1]][curIndex[0]]:
                # mark as covered
                covered[curIndex[1]][curIndex[0]] = 1
                # start BFS
                bfsQue.append(curIndex)
                while bfsQue:
                    curIslandParts = bfsQue[:]
                    bfsQue = []
                    for islandPart in curIslandParts:
                        # up
                        if islandPart[1] - 1 >= 0 and not covered[islandPart[1]-1][islandPart[0]] and grid[islandPart[1]-1][islandPart[0]] == '1':
                            # mark as covered
                            covered[islandPart[1]-1][islandPart[0]] = 1
                            print((islandPart[1]-1, islandPart[0]), 'covered')
                            bfsQue.append((islandPart[0], islandPart[1]-1))
                        # down
                        if islandPart[1] + 1 < len(grid) and not covered[islandPart[1]+1][islandPart[0]] and grid[islandPart[1]+1][islandPart[0]] == '1':
                            # mark as covered
                            covered[islandPart[1]+1][islandPart[0]] = 1
                            print((islandPart[1]+1, islandPart[0]), 'covered')
                            bfsQue.append((islandPart[0], islandPart[1]+1))
                        # left
                        if islandPart[0] - 1 >= 0 and not covered[islandPart[1]][islandPart[0]-1] and grid[islandPart[1]][islandPart[0]-1] == '1':
                            # mark as covered
                            covered[islandPart[1]][islandPart[0]-1] = 1
                            print((islandPart[1], islandPart[0]-1), 'covered')
                            bfsQue.append((islandPart[0]-1, islandPart[1]))
                        # right
                        if islandPart[0] + 1 < len(grid[0]) and not covered[islandPart[1]][islandPart[0]+1] and grid[islandPart[1]][islandPart[0]+1] == '1':
                            # mark as covered
                            covered[islandPart[1]][islandPart[0]+1] = 1
                            print((islandPart[1], islandPart[0]+1), 'covered')
                            bfsQue.append((islandPart[0]+1, islandPart[1]))
                count += 1
        return count
```

我承认我写得很难看。也没有AC。

然后室友帮我写了个。记录下来学习一下。

```python
class Solution(object):
    def numIslands(self, grid):
        """
        :type grid: List[List[str]]
        :rtype: int
        """
        # DFS
        if not grid:
            return 0

        covered = [[0 for i in range(len(grid[0]))] for i in range(len(grid))]
        m = len(grid)
        n = len(grid[0])
        dx = [-1, 1, 0, 0]
        dy = [0, 0, -1, 1]
        def dfs(x, y):
            for i in range(4):
                nx = x + dx[i]
                ny = y + dy[i]
                if   0 <= nx and nx < m and \
                     0 <= ny and ny < n :
                     if grid[nx][ny] == '1' and not covered[nx][ny]:
                        covered[nx][ny] = 1
                        dfs(nx, ny)
        
        def slt():
            count = 0
            for i in range(m):
                for j in range(n):
                    if grid[i][j] == '1' and not covered[i][j]:
                        dfs(i, j)
                        count += 1
            return count
            
        return slt()
```

主要是学习：

1. 用递归深搜的简单方法，比我写的宽搜方便多了。
2. 对于四个方向判断的处理，这个是惊艳到我的。以前没见过，现在涨知识。比起来我那个就太low了。

这个AC了，就记到这里吧。
