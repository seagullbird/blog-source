---
title: "《机器学习实战》读书笔记（一）——CH01&CH02"
date: 2016-09-13T19:18:24+08:00
draft: false
tags: ["Machine Learning", "Python"]
---

《机器学习实战》读书笔记第二篇，第一二章内容总结

<!--more-->

## Chapter 01

- **标称型**和**数值型**：分别从有限和无限目标集中取值。
- **监督学习**：必须知道预测的是什么，即**目标变量**的分类信息。（即总共有哪些类别）
  - **分类**：将实例数据划分到合适的分类中。
  - **回归**：主要用于预测数值型数据。*例：数据拟合曲线——通过给定数据点的最优拟合曲线。*
- **无监督学习**：数据无类别信息，也不会给定目标值。
  - **聚类**：将数据集合分成由类似对象组成的多个类的过程。
  - **密度估计**：寻找描述数据统计值的过程。
- 开发机器学习程序**步骤**：收集数据->准备输入数据->分析输入数据->**训练算法**->**测试算法**。

## Chapter 02 —— k-近邻算法

> 已知样本集中每一数据与所属分类的对应关系，将待定数据的每个特征与样本集中数据对应的特征进行比较，取前k个最相似数据决断。
>
> **简单地说，k-近邻算法采用测量不同特征值之间的距离的方法进行分类。**
>
> **优点**：精度高、对异常值不敏感、无数据输入假定；
>
> **缺点**：计算复杂度高、空间复杂度高；
>
> **适用数据范围：**数值型和标称型。

### 实施kNN算法

代码－kNN.py：

```python
from numpy import *
import operator
def createDataSet():
    group = array([[1.0, 1.1], [1.0, 1.0], [0, 0], [0, 0.1]])
    labels = ['A', 'A', 'B', 'B']
    return group, labels

def classify0(inX, dataSet, labels, k):
    # 距离计算
    # dataSet参数传入的是一个array类型，其shape属性表示数组的维度。这是一个指示数组在每个维度上大小的整数元组。shape[0]为行数，shape[1]为列数
    dataSetSize = dataSet.shape[0]
    # tile(A, reps): 重复A, reps次。reps可以是一个int也可以是一个tuple。
    # 这句把传入的待分类向量纵方向上重复了dataSetSize次，使其成为一个和训练集dataSet相同大小的矩阵，便于之后的计算
    # 从减去dataSet这一步开始，都在进行欧拉距离公式的计算
    diffMat = tile(inX, (dataSetSize, 1)) - dataSet
    sqDiffSet = diffMat**2  # **:求幂运算，前底数后指数
    sqDistances = sqDiffSet.sum(axis=1)
    distances = sqDistances**0.5
    # 上面两句返回纵方向（axis=1）的和并开平方，完成距离计算并返回在一个数组

    # 这句将得到的距离数组排序（从小到大），返回的是排序后的元素在原数组中的序号组成的数组（这些序号同时也是训练集对应的labels在labels数组中的序号）
    sortedDistIndicies = distances.argsort()

    # 选择距离最小的k个点
    # 计算距离前k小元素中各标签label的出现次数，用标签－次数键值对存储在classCount中
    classCount = {}
    for i in range(k):
        voteIlabel = labels[sortedDistIndicies[i]]
        classCount[voteIlabel] = classCount.get(voteIlabel, 0) + 1
    # 排序
    # 将classCount按值的大小从大到小排序
    # key参数说明按待排序对象的第二个属性进行排序
    sortedClassCount = sorted(iter(classCount.items()), key=operator.itemgetter(1), reverse=True)
    return sortedClassCount[0][0]
```

欧式距离公式：
$$
d = \sqrt{(xA_0 - xB_0)^2 + (xA_1 - xB_1)^2}
$$
流程：

1. 获得训练样本集的行数，并将输入向量扩展到和其相同行数（这样便于进行矩阵计算）；
2. 利用公式，对已扩展的输入向量矩阵和训练样本集进行计算，并最终得到包含输入向量和训练样本集中每一个样本的距离的数组；
3. 对距离排序；
4. 对已排序的前k个元素进行目标值频率计算，然后按出现频率将目标值排序；
5. 取出现频率最大的目标值作为返回结果。

------

### 示例：使用k-近邻算法改进约会网站的配对效果

> 流程：收集数据（文本文件）->准备数据（用Python解析文本文件）->分析数据（用Matplotlib画二维扩散图）->训练算法（不适用k-近邻算法）->测试算法（使用提供的部分数据作为测试样本）->使用算法（产生命令行程序）

#### 准备数据（从文本文件中解析）：

```python
def file2matrix(filename):
    fr = open(filename)
    # readlines()将文件的每一行（包括'\n'）作为一个str存在一个list中并返回这个list
    arrayOLines = fr.readlines()
    # 所以len可以得到文件的行数
    numberOfLines = len(arrayOLines)
    # zeros根据传入的tuple作为大小返回一个数值全0的矩阵，这里返回的是3列，numberOfLines行的矩阵
    returnMat = zeros((numberOfLines, 3))
    classLabelVector = []
    index = 0
    for line in arrayOLines:
        # strip()函数去掉后面的'\n'
        line = line.strip()
        # 按'\t'分开这个字符串并将分开后的元素保存到列表
        listFromLine = line.split('\t')
        returnMat[index, :] = listFromLine[0:3]
        classLabelVector.append(int(listFromLine[-1]))
        index += 1
    return returnMat, classLabelVector
```

数据存放在`datingTestSet.txt`中，每个样本数据占一行，共1000行。每行四个数据用`\t`分开，前三个为**特征值**，后一个为**目标值**。

#### 使用Matplotlib分析数据：

交互命令：

```python
>>> import matplotlib
>>> import matplotlib.pyplot as plt
>>> fig = plt.figure()
>>> ax = fig.add_subplot(111)
>>> ax.scatter(datingDataMat[:, 1], datingDataMat[:, 2], 15.0*array(datingLabels), 15.0*array(datingLabels))
>>> plt.show()
```

 ![取后两列数据制作的散点图，横轴为“玩视频游戏所耗时间百分比”，纵轴为“每周消费的冰淇淋公升数”](/images/ml-in-practice-notes-1-figure_1.png)

 ![取前两列数据制作的散点图，横轴为“每年获取的飞行常客里程数”，纵轴为“玩视频游戏所耗时间百分比”](/images/ml-in-practice-notes-1-figure_2.png)

#### 准备数据：归一化数值

将数值的取值范围处理为在0~1或者-1~1之间，以消除不同数量级数值之间的影响。

公式
$$
newValue = (oldValue-min)/(max-min)
$$
其中`min`和`max`分别是数据集中的最小特征值和最大特征值。

代码：

```python
def autoNorm(dataSet):
    minVals = dataSet.min(0)
    maxVals = dataSet.max(0)
    ranges = maxVals - minVals
    normDataSet = zeros(shape(dataSet))
    m = dataSet.shape[0]
    normDataSet = dataSet - tile(minVals, (m, 1))
    normDataSet = normDataSet / tile(ranges, (m, 1))
    return normDataSet, ranges, minVals
```

#### 测试算法

取样本集中的一部分作为测试数据集。

代码：

```python
def datingClassTest():
    # 测试样本集占总样本集的比例
    hoRatio = 0.10
    datingDataMat, datingLabels = file2matrix('datingTestSet2.txt')
    normMat, ranges, minVals = autoNorm(datingDataMat)
    m = normMat.shape[0]
    numTestVecs = int(m * hoRatio)
    errorCount = 0.0
    for i in range(numTestVecs):
        classifierResult = classify0(normMat[i, :], normMat[numTestVecs:m, :], datingLabels[numTestVecs:m], 5)
        print("The classifer came back with : %d, the real answer is: %d" % (classifierResult, datingLabels[i]))
        if classifierResult != datingLabels[i]:
            errorCount += 1.0
    print("The total error rate is: %f"  %  (errorCount/float(numTestVecs)))
```

#### 完整可用系统

```python
def classifyPerson():
    resultList = ['not at all', 'in small doses', 'in large doses']
    percentTats = float(input('Percentage of time spent playing video games?'))
    ffMiles = float(input('Frequent flier miles earned per year?'))
    iceCream = float(input('Liters of ice cream consumed per year?'))
    datingDataMat, datingLabels = file2matrix('datingTestSet2.txt')
    normMat, ranges, minVals = autoNorm(datingDataMat)
    inArr = array([ffMiles, percentTats, iceCream])
    classifierResult = classify0((inArr-minVals)/ranges, normMat, datingLabels, 3)
    print('You will probably like this person: ', resultList[classifierResult-1])
```

------



### 手写识别系统

#### 步骤

- 收集数据：提供32*32像素格式的txt文件
- 准备数据：编写函数img2vector()将文本文件转换为样本矩阵
- 分析数据：在命令提示符中检验数据正确性
- 训练算法：不适用于k-近邻算法
- 测试算法：使用部分数据集作为测试样本

#### 准备数据

使用trainingDigits中的大约2000个例子作为样本，平均每个0~9的数字有200个样本。使用testDigits目录下的测试数据作为测试。

代码：

```python
def img2vector(filename):
    returnVect = zeros((1, 1024))
    fr = open(filename)
    for i in range(32):
        lineStr = fr.readline()
        for j in range(32):
            returnVect[0, 32*i+j] = int(lineStr[j])
    return returnVect
```

该函数创建1*1024的NumPy数组，然后打开给定的文件，循环读出前32行，并将每行的头32个字符值存储在NumPy数组中，最后返回数组。

#### 测试算法

测试代码：

```python
def handwritingClassTest():
    hwLabels = []
    trainingFileList = listdir('trainingDigits')
    m = len(trainingFileList)
    trainingMat = zeros((m, 1024))
    for i in range(m):
        fileNameStr = trainingFileList[i]
        fileStr = fileNameStr.split('.')[0]
        classNumStr = int(fileStr.split('_')[0])
        hwLabels.append(classNumStr)
        trainingMat[i, :] = img2vector('trainingDigits/%s' % fileNameStr)
    testFileList = listdir('testDigits')
    errorCount = 0.0
    mTest = len(testFileList)
    for i in range(mTest):
        fileNameStr = testFileList[i]
        fileStr = fileNameStr.split('.')[0]
        classNumStr = int(fileStr.split('_')[0])
        vectorUnderTest = img2vector('testDigits/%s' % fileNameStr)
        classifierResult = classify0(vectorUnderTest, trainingMat, hwLabels, 3)
        print('The classifer came back with: %d, the real answer is: %d' % (classifierResult, classNumStr))
        if classifierResult != classNumStr:
            errorCount += 1.0
    print('\nThe total number of errors is: %d' % errorCount)
    print('\nThe total error rate is: %f' % (errorCount/float(mTest)))
```

结果：

```python
>>> kNN.handwritingClassTest()
The classifer came back with: 0, the real answer is: 0
The classifer came back with: 0, the real answer is: 0
The classifer came back with: 0, the real answer is: 0
        .
        .
        .
     
The classifer came back with: 9, the real answer is: 9
The classifer came back with: 9, the real answer is: 9
        
The total number of errors is: 11

The total error rate is: 0.011628
```

修改函数随机选取训练样本，改变训练样本的数目，都会对错误率造成影响。

实际使用这个算法时，执行效率不高。算法需要为每个测试向量做2000次距离计算，每个距离计算包含了1024个维度浮点运算，总计执行900次。此外，还要为测试向量准备2MB的存储空间。

### 本章总结

>  k-近邻算法是基于实例的学习，使用算法时我们必须有接近实际数据的训练样本数据。k-近邻算法必须保存全部数据集，如果训练数据集很大，必须使用大量内存空间。此外，由于必须对数据集中每个数据计算距离值，实际使用时可能非常耗时。
>
>  k-近邻算法的另一个缺陷是它无法给出任何数据的基础结构信息，因此我们也无法知晓平均实例样本和典型实例样本具有什么特征。
