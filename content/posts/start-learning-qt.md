---
title: "QT入门－－积累与整理"
date: 2016-06-01T10:48:26+08:00
draft: false
tags: ["Qt"]
---

这学期开始学习了QT，越用越觉得这个C++库的强大。一直没来得及整理学到的知识，现在慢慢整理如下。

<!--more-->

## QDebug
QT里面“QDebug”有几种写法（对应不同的类或方法），这里只记录我用过的`qDebug()`。使用时需要`#include <QDebug>`。用法如下：

~~~~C++
QString str;
QDatetime currentDateTime;
qDebug() << str;
qDebug() << currentDateTime;
~~~~
程序会在控制台按一定格式打印出该对象并且自动换行。调试程序时非常实用，由于是QT自己的类，所以打印时比单纯`cout`友好得多。（事实上显然`cout`根本不能直接打印出上面那两个对象）。

## QMessageBox
QMessageBox的效果是弹出一个提示框，非常有用。使用时需要先`#include <QMessageBox>`。有如下几种用法：

~~~~C++
    QMessageBox::information(this, "Error", "Can't Open File!");
    QMessageBox::warning(this, "Error", "Can't Open File!");
~~~~

这样程序运行后会显示第三个参数所输入的句子，并且只有一个确定键可以点，点完就消失。适用于测试程序时打印某一个变量，或者提示一些信息（像这个例子一样）等。

~~~~C++
    QMessageBox::StandardButton reply;
    reply = QMessageBox::question(this, "Are you Sure?", "This will delete a whole club!", QMessageBox::Yes | QMessageBox::No);
    if(reply == QMessageBox::Yes)
    {
        //Insert your code here...
    }
~~~~

这样弹出的对话框会有一个确定键一个取消键，这段代码描述了如果用户点了确定键，程序应该执行什么事情。适用于提示用户是否要进行某些操作等时候。

## QString
QT自己的字符串类，功能非常强大。同C++ string类一样同样重载了+运算符，可以直接实现两个QString的拼接。同时拥有一系列的类型转换方法，对于string、int、double等（还有很多，这几个较常用）变量类型均可一步转换：

~~~~C++
    int a;
    double b;
    string c;
    QString as = "1";
    QString bs = "2.22";
    QString cs = "asdfsdf";
    a = as.toInt();
    b = bs.toDouble();
    c = cs.toStdString();
~~~~

或者：

~~~~C++
    cs = QString::fromStdString(c);
    bs = QString::number(b);
    as = QString::number(a);
~~~~

## QFile
QT的文件操作类。可以以多种模式打开文件并进行读写（使用对应的方法）：

~~~~C++
    QFile *file = new QFile(QCoreApplication::applicationDirPath() + "/Database.txt");
    file->open(QIODevice::ReadOnly|QIODevice::Text);
    if(!file->isOpen())
        QMessageBox::information(this, "Error", "Can't Open File!");
    else
        string data = QString(file->readLine()).remove("\n").toStdString();
    file->close(); 
~~~~
`readline()`函数完整地读取文件中的一行内容（包括换行符），如果想去掉换行符可以使用`remove("\n")`。
顺便在这里说一下文件打开路径的问题。
如果初始化QFile对象时只给出文件名，（`QFile *file = new QFile("File.txt");`）则编译器会自动在程序工作路径下寻找文件。一般在`program.app/Contents/MacOS/`目录下。这样做在QT Creator中运行程序是没有问题的，但如果直接双击编译目录下的`program.app`程序则无法成功读取文件。要解决这个办法可以像上面例子中一样，将文件路径设置为`QCoreApplication::applicationDirPath() + "/Database.txt"`,则在本地直接双击app程序可以成功读取文件。但是目前发现如果将app程序打包成dmg并安装到另一台电脑上这种方法仍然不能成功打开文件。先存疑，以后遇到再解决这个问题。

## 输入输出流
QT的输入输出流是和输入输出设备（QIODevice）（如：QFile，QByteArray）紧密联合在一起的。目前用过的输入输出设备包括QTextStream、QDataStream。使用时需要include对应的头文件。同样用例子说明：

~~~~C++
    QFile *file = new QFile(QCoreApplication::applicationDirPath() + "/Database.txt");
    file->open(QIODevice::Truncate | QIODevice::WriteOnly);
    if(!file->isOpen())
        QMessageBox::information(this, "Error", "Can't Open File!");
    else
    {
        QTextStream out(file);
        QString str = "sadf";
        out << "str" << endl;
    }
    file->close();
~~~~
这样就能将内存中str对象所保存的QString内容输出到文件中保存。另外，使用QDataStream在不重载输入输出运算符(>>和<<)的情况下同样可以将C++中基本数据类型（int, double, char等）以及QT自带数据类型（如QString）输入到QByteArray对象以字节流的形式保存：

~~~~C++
    QByteArray msgSent;
    QString type = "UNSELL";
    QDataStream sendStream(&msgSent, QIODevice::WriteOnly);
    sendStream << type << clubClient << curClub->getName() << playerID;
    clientConnection->write(msgSent);
~~~~
输出时只需：

~~~~C++
    QByteArray msgRecv = client->readAll();
    QDataStream recvStream(&msgRecv, QIODevice::::ReadOnly);
    QString type, clubClient, playerID, clubServer;
    recvStream >> type >> clubClient >> clubServer >> playerID;
~~~~

如果想要处理自定义数据类型则需要重载输入输出运算符，下面以重载输出运算符<<为例：

~~~~C++
    typedef struct {
        int data;
        double number;
    }Example;
    
    QDataStream &operator<<(QDataStream &out, const Example &input)
    {
        out << input.data << input.number;
        return out;
    }
~~~~
如上，因为<<本身不支持对于自定义结构体`Example`的输出，通过重载我们同样可以直接`out << ex`将ex（一个Example结构体）输出到字节流。而字节流的接受方想要通过`in >> ex`方式接收一个ex结构体的话，需要重载>>运算符：

~~~~C++
    QDataStream &operator>>(QDataStream &in, Example &output)
    {
        int dataRecv;
        double numberRecv;
        in >> dataRecv >> numberRecv;
        output.data = dataRecv;
        output.number = numberRecv;
        return in;
    }
~~~~

## QTcpSocket
QT有封装好的TCP Socket类，可以实现Socket通信。使用时需先在项目`.pro`文件中添加`QT += network`，并`#include <QtNetwork>`。这方面目前我没有深入研究，仅仅为了解决问题而借鉴了别人的代码，实现了同一计算机上两个进程间的简单通信。

### TCP client端
~~~~C++
    #include <QtNetwork>
    QTcpSocket *client;
    char *data = "hello qt!";
    client = new QTcpSocket(this);
    client->connectToHost(QHostAddress("127.0.0.1"), 1234);
    client->write(data);
~~~~

### TCP server端
~~~~C++
    #include <QtNetwork>
    QTcpServer *server;
    QTcpSocket *clientConnection;
    server = new QTcpServer();
    server->listen(QHostAddress::Any, 1234);
    connect(server, SIGNAL(newConnection()), this, SLOT(acceptConnection()));
    void acceptConnection()
    {
        clientConnection = server->nextPendingConnection();
        connect(clientConnection, SIGNAL(readyRead()), this, SLOT(readClient()));
    }
    void readClient()
    {
        QString str = clientConnection->readAll();
        //或者
        char buf[1024];
        clientConnection->read(buf,1024);
    }
~~~~

要知道，例子中`client->write()`和`clientConnection->read();`或`clientConnection->readAll();`等函数都可以接受`QByteArray`类的对象作为参数或者返回值，所以要想通过这种方式传输自定义类型数据只需按上一个标题中讲的一样将数据输入到`QByteArray`字节流并发送或接收。

## QCloseEvent
想要在程序关闭时询问用户或是保存文件？重载QCloseEvent函数能够做到这些。在mainwindow.h中声明函数`void closeEvent(QCloseEvent *event)`。同时别忘记`#include <QCloseEvent>`。

~~~~C++
void MainWindow::closeEvent(QCloseEvent *event)
{
    QFile *file = new QFile(QCoreApplication::applicationDirPath() + "/" + system_type + ".txt");
    file->open(QIODevice::Truncate | QIODevice::WriteOnly);
    if(!file->isOpen())
        QMessageBox::information(this, "Error", "Can't Open File!");
    else
    {
        //保存文件
    }
    event->accept();    //接受关闭程序事件
}
~~~~

<br><br>
暂时想不起来什么了，信号与槽的内容我现在所了解的都还太浅显不足以记一笔，以后要是有深入学习再记吧。
