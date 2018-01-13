---
title: "《机器学习实战》读书笔记（二）——决策树"
date: 2016-09-16T09:50:31+08:00
draft: false
tags: ["Machine Learning", "Python"]
---

k-近邻算法可以完成很多分类任务，但是它最大的缺点就是无法给出数据的内在含义，决策树的主要优势就在于数据形式非常容易理解。

<!--more-->

## 决策树的构造

> **优点**：计算复杂度不高，输出结果易于理解，对中间值的缺失不敏感，可以处理不相关特征数据。
>
> **缺点**：可能会产生**过度匹配**问题。
>
> **适用数据类型**：数值型和标称型。

递归方法划分数据集，直至当前数据子集内的所有数据属于同一类型。

> **决策树的一般流程**
>
> 1. 收集数据：任何方法
> 2. 准备数据：树构造算法只适用于标称型数据，因此**数值型数据必须离散化**
> 3. 分析数据：任何方法，构造树完成之后，应该检查图形是否符合预期
> 4. 训练算法：构造树的数据结构
> 5. 测试算法：使用经验树计算错误率
> 6. 使用算法：此步骤适用于任何监督学习算法，而**使用决策树可以更好地理解数据的内在含义**

采用**ID3算法**划分数据集。

### 信息增益

> 在划分数据集之前之后发生的变化称为**信息增益(information gain)**。知道如何计算信息增益，就可以计算每个特征值划分数据集获得的信息增益，**获得信息增益最高的特征就是最好的选择。**

**香农熵/熵(entropy)：**集合信息的度量方式。定义为**信息的期望值**。**是一个负数。**

**信息的定义：如果待分类的事务可能划分在多个分类之中，则符号xi的信息定义为：l(xi) = -log2p(xi)**。其中xi是选择该分类的概率。

**所有类别所有可能值包含的信息期望值：p35**

计算香农熵

代码trees.py:

```python
from math import log
def calcShannonEnt(dataSet):
    numEntries = len(dataSet)
    labelCounts = {}
    for featVec in dataSet:
        currentLabel = featVec[-1]
        if currentLabel not in labelCounts.keys():
            labelCounts[currentLabel] = 0
        labelCounts[currentLabel] += 1
    shannonEnt = 0.0
    for key in labelCounts:
        prob = float(labelCounts[key])/numEntries
        shannonEnt -= prob * log(prob, 2)
    return shannonEnt
```

**熵的绝对值越大（越往负的方向远离0），混合的数据就越多，即表示分类越多，数据集的无序程度越高。**

### 划分数据集

对每个特征划分数据集的结果计算一次信息熵，然后判断按照哪个特征划分数据集是最好的划分方式。

代码trees.py:

```python
# 按照给定特征划分数据集
def splitDataSet(dataSet, axis, value):
    retDataSet = []
    for featVec in dataSet:
        if featVec[axis] == value:
            reducedFeatVec = featVec[:axis]
            reducedFeatVec.extend(featVec[axis+1:])
            #reducedFeatVec和featVec的差别在于reducedFeatVec没有featVec[axis]
            retDataSet.append(reducedFeatVec)
    return retDataSet
```

三个参数：**待划分的数据集，划分数据集的特征，需要返回的特征的值。**

另外，对于`List`对象的自带函数`extend()`和`append()`:

```python
>>> a = [1,2,3]
>>> b = [4,5,6]
>>> a.append(b)
>>> a
[1, 2, 3, [4, 5, 6]]
>>> a = [1,2,3]
>>> a.extend(b)
>>> a
[1, 2, 3, 4, 5, 6]
```

函数运行结果示例：

```python
>>> import trees
>>> myDat, labels = trees.createDataSet()
>>> myDat
[[1, 1, 'yes'], [1, 1, 'yes'], [1, 0, 'no'], [0, 1, 'no'], [0, 1, 'no']]
>>> trees.splitDataSet(myDat, 0, 1)
[[1, 'yes'], [1, 'yes'], [0, 'no']]
>>> trees.splitDataSet(myDat, 0, 0)
[[1, 'no'], [1, 'no']]
```

接下来就是遍历整个数据集，循环计算香农熵和`splitDataSet()`函数，找到最好的特征划分方式。

```python
# 选择最好的数据集划分方式
def chooseBestFeatureToSplit(dataSet):
    # 初始化
    numFeatures = len(dataSet[0]) - 1 
    baseEntropy = calcShannonEnt(dataSet)
    bestInfoGain = 0.0
    bestFeature = -1
    # 开始遍历
    for i in range(numFeatures):
        # i为特征值坐标，用i遍历相当于遍历每条数据的某单个特征
        featList = [example[i] for example in dataSet]
        # uniqueVals存储的是这个特征值在这个数据集中所有不重复的可能取值
        uniqueVals = set(featList)
        newEntropy = 0.0
        # 遍历当前特征中的所有唯一属性值，对每个属性值划分一次数据集，然后计算新熵值
        for value in uniqueVals:
            subDataSet = splitDataSet(dataSet, i, value)
            # 加权求和
            prob = len(subDataSet)/float(len(dataSet))
            newEntropy += prob * calcShannonEnt(subDataSet)
        # 最后所得新熵值即是由该特征下每一唯一特征值进行划分计算的香农熵的加权求和
        # 信息增益是熵（的绝对值）的减少或者是数据无序度的减少，所以infoGain即是按该特征值划分之后较之前的信息增益
        infoGain = baseEntropy - newEntropy
        if infoGain > bestInfoGain:
            bestInfoGain = infoGain
            bestFeature = i
    return bestFeature
```

在该函数中调用的数据需要满足一定的要求：

1. **数据必须是一种由列表元素组成的列表，而且所有的列表元素要具有相同的长度；**
2. **数据的最后一列，即每个实例的最后一个元素是当前实例的类别标签。**

满足上述要求的数据即可在函数第一行判定当前数据集包含多少特征属性。

------

到此为止自己的一些理解：

熵的定义是信息的期望值，是数据的无序程度，划分的目标是尽量降低数据的无序程度，使无序变有序。

按照给定特征划分数据集时，传入的是数据集，特征在数据集中的列号`axis`，该特征的值`value`。做的事情是返回**该列值为`value`但是不包含该列的、原数据集的子集**。也就即是，当该列对应的特征的属性值为`value`时的一个划分。那么计算这个子集的香农熵，就得到这个子集的无序度。

对于原数据集来说，关于某个特征（某一列）的所有属性值（假设有n个）的划分，就将原数据集划分成了n个子集，每个子集的该特征值互不相同（但是该特征占的这一列已经不在每个子集中）。

而这等价于，对每个划分后的子集来说，都已经知道了该特征的值，那么它的熵就是在已知该特征值的条件下的熵，叫做**条件熵**。

当某一个特征的值固定时，条件熵等于当该特征固定在其所有可能属性值上（即上面说的每个子集）的熵的均值，即加权求和。简单理解就是，一个值出现的可能性较大，那么在他上面算出来的信息量（即熵）占的比重就应该多一些。

### 递归构建决策树

工作原理：

- 得到原始数据集
- 基于最好的属性值划分数据集（由于特征值可能多于两个， 因此可能存在大于两个分支的数据集划分。）
- 第一次划分后，数据将被向下传递到树分支的下一个节点，在这个节点上再次划分数据。
- 采用递归的原则处理数据集。

递归结束的条件是：**程序遍历完所有划分数据集的属性，或者每个分支下的所有实例都具有相同的分类。如果所有实例都具有相同的分类，则得到一个叶子节点。**

如果数据集已经处理了所有属性，但是类标签依然不是唯一的，此时需要采用**多数表决法**决定该叶子节点的分类。

```python
def majorityCnt(classList):
    classCount = {}
    for vote in classList:
        if vote not in classCount.keys(): 
            classCount[vote] = 0
        classCount[vote] += 1
    sortedClassCount = sorted(iter(classCount.items()), key=operator.itemgetter(1), reverse=True)
    return sortedClassCount[0][0]
```

该函数参数为所有分类名称的列表`classList`，然后创建键值为`classList`中唯一值的数据字典，字典对象存储了`classList`中每个类标签出现的频率，最后排序字典，并返回出现次数最多的分类名称。要注意，`sortedClassCount`不是一个字典对象，而是一个列表对象，其中每个元素为一个`tuple`，每个`tuple`的第一个元素是原字典的键值（分类名称），第二个元素是原字典中该键值对应的值。

创建树的代码：

```python
# 创建树的函数
# 两个参数：数据集和特征名称列表
# 特征名称列表包含数据集中所有特征的名称，算法本身不需要这个变量，提供仅是为了给出数据明确的含义
def createTree(dataSet, labels):
    # 获得数据集的所有类标签
    classList = [example[-1] for example in dataSet]
    # 如果所有类别完全相同则停止划分，直接返回该标签
    if classList.count(classList[0]) == len(classList):
        return classList[0]
    # 如果已经使用完了所有特征（数据集中只剩一列，就是末尾的类标签），则按照多数表决法返回出现次数最多的标签
    if len(dataSet[0]) == 1:
        return majorityCnt(classList)
    # 开始创建树
    # 选择最合适的划分特征(bestFeat是该特征在数据集中的列号,int)
    bestFeat = chooseBestFeatureToSplit(dataSet)
    # 根据bestFeat从特征名称列表中获得该特征的名称
    bestFeatLabel = labels[bestFeat]
    # 采用字典存储树，键值为划分的特征名
    myTree = {bestFeatLabel : {}}
    # 删除特征名称列表中的该特征
    del labels[bestFeat]
    # 获得该数据集中该特征下的所有属性值，并利用set去重
    featValues = [example[bestFeat] for example in dataSet]
    uniqueVals = set(featValues)
    # 对于每一个不同的属性
    for value in uniqueVals:
        # 复制labels
        subLabels = labels[:]
        # myTree在当前最好特征下的值是另一个以该特征的某一个属性值为键值的字典。它的值是myTree的子树（或者叶子节点，返回的是分类名称）
        myTree[bestFeatLabel][value] = createTree(splitDataSet(dataSet, bestFeat, value), subLabels)
    return myTree
```

代码详解都在注释里，这里强调一下`subLabels = labels[:]`和`subLabels = labels`的区别：

两句语句得到的`subLabels`内容是一样的。区别在于，第二种方式得到的`subLabels`其实和原始的`labels`一摸一样，相当于两个指针指向同一块内存地址。而第一种方式得到的`subLabels`是值和`labels`一样，但完全不用的另一个`List`对象。简单理解，它的意思相当于把`labels`列表中的元素从头到尾复制给`subLabels`。而第二种相当于只是给`labels`这个`List`另外取了一个名字。

用python自带的`id()`函数（返回对象的内存地址）可以验证上述：

```python
>>> l
[1, 2, 3, 4, 5]
>>> s = l
>>> id(s)
4537415752
>>> id(l)
4537415752
>>> s = l[:]
>>> id(s)
4537416392
>>> id(l)
4537415752
```

那么这段代码之所以要用`subLabels = labels[:]`而不用`subLabels = labels`，是为每次调用`createTree()`时不改变原始列表内容。

构造树测试：

```python
>>> import trees
>>> myDat, labels = trees.createDataSet()
>>> myDat
[[1, 1, 'yes'], [1, 1, 'yes'], [1, 0, 'no'], [0, 1, 'no'], [0, 1, 'no']]
>>> labels
['no surfacing', 'flippers']
>>> myTree = trees.createTree(myDat, labels)
>>> myTree
{'no surfacing': {0: 'no', 1: {'flippers': {0: 'no', 1: 'yes'}}}}
```

## 使用Matplotlib绘制树形图

代码见`treePlotter.py`。

![初始图](/images/ml-in-practice-notes-2-figure_1.png)

![超过两个分支的树形图](/images/ml-in-practice-notes-2-figure_2.png)

## 测试和存储分类器

### 测试算法：使用决策树执行分类

代码trees.py：

```python
def classify(inputTree, featLabels, testVec):
    firstStr = list(inputTree.keys())[0]
    secondDict = inputTree[firstStr]
    featIndex = featLabels.index(firstStr)
    for key in secondDict.keys():
        if testVec[featIndex] == key:
            if type(secondDict[key]).__name__ == 'dict':
                classLabel = classify(secondDict[key], featLabels, testVec)
            else:
                classLabel = secondDict[key]
    return classLabel
```

很简单的递归判断。

### 决策树的存储

使用python模块`json`序列化对象，将对象保存在硬盘上。

```python
import json
def storeTree(inputTree, filename):
    fw = open(filename, 'w')
    json.dump(inputTree, fw)
    fw.close()

def grabTree(filename):
    fr = open(filename)
    return json.load(fr)
```

要注意，序列化后的对象中的键值都变成了`str`类型。

运行实例：

```python
>>> import trees
>>> myDat, labels = trees.createDataSet()
>>> myTree = trees.grabTree('classifierStorage.txt')
>>> myTree
{'no surfacing': {'1': {'flippers': {'1': 'yes', '0': 'no'}}, '0': 'no'}}
>>> trees.classify(myTree, labels, ['1','1'])
'yes'
>>> trees.classify(myTree, labels, ['1','0'])
'no'
```

## 示例：使用决策树预测隐形眼镜类型

流程：

- 收集数据：提供的文本文件`lenses.txt`（数据来源于UCI数据集）
- 准备数据：解析文本文件中的数据
- 分析数据：快速检查数据，确保正确地解析了数据内容。使用`createPlot()`函数绘制最终的树形图
- 训练算法：使用前面的`createTree()`函数
- 测试算法：编写测试函数验证决策树可以正确分类给定数据实例
- 使用算法：存储树的数据结构

```python
>>> import trees
>>> import treePlotter
>>> fr = open('lenses.txt')
>>> lenses = [inst.strip().split('\t') for inst in fr.readlines()]
>>> lenses
[['young', 'myope', 'no', 'reduced', 'no lenses'], ['young', 'myope', 'no', 'normal', 'soft'], ['young', 'myope', 'yes', 'reduced', 'no lenses'], ['young', 'myope', 'yes', 'normal', 'hard'], ['young', 'hyper', 'no', 'reduced', 'no lenses'], ['young', 'hyper', 'no', 'normal', 'soft'], ['young', 'hyper', 'yes', 'reduced', 'no lenses'], ['young', 'hyper', 'yes', 'normal', 'hard'], ['pre', 'myope', 'no', 'reduced', 'no lenses'], ['pre', 'myope', 'no', 'normal', 'soft'], ['pre', 'myope', 'yes', 'reduced', 'no lenses'], ['pre', 'myope', 'yes', 'normal', 'hard'], ['pre', 'hyper', 'no', 'reduced', 'no lenses'], ['pre', 'hyper', 'no', 'normal', 'soft'], ['pre', 'hyper', 'yes', 'reduced', 'no lenses'], ['pre', 'hyper', 'yes', 'normal', 'no lenses'], ['presbyopic', 'myope', 'no', 'reduced', 'no lenses'], ['presbyopic', 'myope', 'no', 'normal', 'no lenses'], ['presbyopic', 'myope', 'yes', 'reduced', 'no lenses'], ['presbyopic', 'myope', 'yes', 'normal', 'hard'], ['presbyopic', 'hyper', 'no', 'reduced', 'no lenses'], ['presbyopic', 'hyper', 'no', 'normal', 'soft'], ['presbyopic', 'hyper', 'yes', 'reduced', 'no lenses'], ['presbyopic', 'hyper', 'yes', 'normal', 'no lenses']]
>>> lensesLabels = ['age', 'prescript', 'astigmatic', 'tearRate']
>>> lensesTree = trees.createTree(lenses, lensesLabels)
>>> lensesTree
{'tearRate': {'normal': {'astigmatic': {'yes': {'prescript': {'myope': 'hard', 'hyper': {'age': {'pre': 'no lenses', 'young': 'hard', 'presbyopic': 'no lenses'}}}}, 'no': {'age': {'pre': 'soft', 'young': 'soft', 'presbyopic': {'prescript': {'myope': 'no lenses', 'hyper': 'soft'}}}}}}, 'reduced': 'no lenses'}}
>>> treePlotter.createPlot(lensesTree)
```

构建的决策树如下：

![由ID3算法产生的决策树](/images/ml-in-practice-notes-2-figure_3.png)

## 本章小结

> 开始处理数据集时，先要测量数据集中数据的不一致性，即熵，然后寻找最优方案（熵增最多）划分数据集，直到数据集中所有数据属于同一分类。ID3算法可以用于划分标称型数据集。
>
> 隐形眼镜的例子表明决策树可能会产生过多的数据集划分，从而产生**过度匹配**数据集的问题。可以通过裁决决策树，合并相邻的无法产生大量信息增益的叶节点，消除过度匹配问题。
>
> 还有其他的决策树构造方法，最流行的是`C4.5`和`CART`。
>
> 决策树算法和k-近邻算法讨论的是结果确定的分类算法，数据最终会被明确划分到某个分类中。
