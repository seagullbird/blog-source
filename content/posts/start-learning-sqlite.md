---
title: "初学Sqlite的一些积累和思考"
date: 2016-03-27T11:26:10+08:00
draft: false
tags: ["SQLite"]
---

现在是大二下学期，大作业旅行管理系统尝试使用了数据库，因为数据量不大所以选择了轻量型的Sqlite。据官网API来看相对于Mysql等大型数据库管理系统Sqlite有他更快的读取速度和更小巧的体积和搭建方式。API自己就说Sqlite是用来替代`fopen()`的（笑）。于是高兴地入了坑，又重温了一遍Sql。

<!--more-->

## SQL
### SELECT
这里只说一件事：如果想从两张（及以上）的表中同时查询，而查询的字段中又有字段（比如“ID”）同时存在于两张（及以上）表中，处理不好就会很容易出现`ambiguous column name: ID`（ID字段冲突）的报错。比如如下两张表：

table1

ID | NUMBER | Third Header
------------ | ------------- | ---
1 | Content Cell  | Content Cell
2 | Content Cell  | Content Cell

table2

ID | NUMBER | Third Header
------------ | ------------- | ---
1 | Content Cell  | Content Cell
2 | Content Cell  | Content Cell

如果你这样：

```sql
SELECT ID FROM table1, table 2 WHERE ID < 2;
```

就会得到
`ambiguous column name: ID`
因为系统不能判断你是想从哪张表的ID里面SELECT，**虽然可能在你看来两张表的ID字段是一模一样的。**

正确的做法是用表名.字段名指名需要查找的是哪个表的字段，并将在不同表中理应相等的字段用等号连接（即显式注明你认为本来一样的字段）：

```sql
SELECT table1.NUMBER, table2.ID FROM table1, table2
WHERE table1.ID = table2.ID
AND table.ID < 2;
```

嫌`table_name.column_name`格式太长可以使用sql别名：

```sql
SELECT C.ID, C.NAME, C.AGE, D.DEPT
FROM COMPANY AS C, DEPARTMENT AS D
WHERE  C.ID = D.EMP_ID; 
```
最开始遇到这个问题时我用了三张表来表示一趟航班的所有信息：

* 第一张表包含ID，起始城市和到达城市；
* 第二张表包含完全相同的ID，航班的时间信息（起降时间，飞行时间等）；
* 第三张表包含完全相同的ID，航班的价格信息。

最开始的思路是通过相同的ID将三张表相连接，然后根据ID将一趟航班的所有信息一句SQL查询出来。然后发现总是会出现上面提到的问题，最后终于在想了一个晚上没结果，关了电脑躺下后突然想到了上面的解决方案。如果真的遇到这样的问题无法避免，我的想法是把三张表在脑中合成一张表，要查找这张大表中的某一条记录肯定需要使三个ID相等，然后用AND连接其他的conditions。

**但其实，我这道题根本不用使用三张表来保存（囧）**也不知道自己当时是怎么想的非要用三张表来折腾自己。。现在直接在一张表上保存一趟航班所有信息，一句SQL轻松查询。

### Sqlite内置函数
SQLite 有许多内置函数用于处理字符串或数字数据。下面列出了一些有用的 SQLite 内置函数，且所有函数都是大小写不敏感，这意味着您可以使用这些函数的小写形式或大写形式或混合形式。欲了解更多详情，请查看 SQLite 的[官方文档](http://sqlite.org/docs.html)。

>序号 函数 & 描述

>1. SQLite COUNT 函数
SQlite COUNT 聚集函数是用来计算一个数据库表中的行数。
2.  SQLite MAX 函数
SQLite MAX 聚合函数允许我们选择某列的最大值。
3.  SQLite MIN 函数
SQLite MIN 聚合函数允许我们选择某列的最小值。
4.  SQLite AVG 函数
SQLite AVG 聚合函数计算某列的平均值。
5.  SQLite SUM 函数
SQLite SUM 聚合函数允许为一个数值列计算总和。
6.  SQLite RANDOM 函数
SQLite RANDOM 函数返回一个介于 -9223372036854775808 和 +9223372036854775807 之间的伪随机整数。
7.  SQLite ABS 函数
SQLite ABS 函数返回数值参数的绝对值。
8.  SQLite UPPER 函数
SQLite UPPER 函数把字符串转换为大写字母。
9.  SQLite LOWER 函数
SQLite LOWER 函数把字符串转换为小写字母。
10. SQLite LENGTH 函数
SQLite LENGTH 函数返回字符串的长度。
11. SQLite sqlite_version 函数
SQLite sqlite_version 函数返回 SQLite 库的版本。

这些函数非常有用，可以省很多事。下面就有例子。


### GROUP BY
SQLite 的 GROUP BY 子句用于与 SELECT 语句一起使用，来对相同的数据进行分组。
在 SELECT 语句中，GROUP BY 子句放在 WHERE 子句之后，放在 ORDER BY 子句之前。

很简单但很实用的一句用法，目前的代码最终版中仍然有这一句。
比如，如果要查找路线为成都到所有与之互通航班的城市中价格最低的一趟航班的所有信息，可以写：

```sql
SELECT FLIGHT_NUMBER, START, END, DEPARTURE_TIME, ARRIVAL_TIME, ... ,MIN(PRICE)
FROM FLIGHT_INFO
WHERE START = 'CHENGDU';
```

这样会查出从成都发出价格最低的一趟航班。它可以是到重庆的，也可以是到哈尔滨的，终点不定。但如果要求是给出到每个城市的最低价航班呢？GROUP BY就派上用场了：

```sql
SELECT FLIGHT_NUMBER, START, END, DEPARTURE_TIME, ARRIVAL_TIME, ... ,MIN(PRICE)
FROM FLIGHT_INFO
WHERE START = 'CHENGDU'
GROUP BY END;
```

此处END即为终点城市，这样查询就可以查出成都到每一个与之相连的城市的最低价航班信息。即成都与多少个城市相连，就会（至少）给出多少条信息。

由于不排除有到同一个城市价格一样且最低的航班，所以加上至少。

我们这里用了**内置函数MIN**，查出最低价格仅需将PRICE改为MIN(PRICE)，是不是灰常方便！
另外，MIN（以及其他可能函数）还可以这样用：

~~~sql
SELECT MIN(0.3*PRICE + 0.7*ARRIVAL_TIME) AS MIX FROM ALL_INFO
WHERE START = 'CHENGDU';
~~~
用于对表中值的按权重混合搜索。


## C/C++ 接口
典型的函数操作流程：

~~~~C++
/* create a statement from an SQL string */  
sqlite3_stmt *stmt = NULL;  
sqlite3_prepare_v2( db, sql_str, sql_str_len, &stmt, NULL );  
  
/* use the statement as many times as required */  
while( ... )  
{  
    /* bind any parameter values */  
    sqlite3_bind_xxx( stmt, param_idx, param_value... );  
    ...  
    /* execute statement and step over each row of the result set */  
    while ( sqlite3_step( stmt ) == SQLITE_ROW )  
    {  
        /* extract column values from the current result row */  
        col_val = sqlite3_column_xxx( stmt, col_index );  
        ...  
    }  
  
    /* reset the statement so it may be used again */  
    sqlite3_reset( stmt );  
    sqlite3_clear_bindings( stmt );  /* optional */  
}  
  
/* destroy and release the statement */  
sqlite3_finalize( stmt );  
stmt = NULL;  
~~~~
这段程序首先调用`sqlite3_prepare_v2`函数，将一个SQL命令字符串转换成一条prepared语句，存储在`sqlite3_stmt`类型结构体中。随后调用`sqlite3_bind_xxx`函数给这条prepared语句绑定参数。然后不停的调用`sqlite3_step`函数执行这条prepared语句，获取结果集中的每一行数据，从每一行数据中调用`sqlite3_column_xxx`函数获取有用的列数据，直到结果集中所有的行都被处理完毕。

prepared语句可以被重置（调用`sqlite3_reset`函数），然后可以重新绑定参数之后重新执行。**`sqlite3_prepare_v2`函数代价昂贵，所以通常尽可能的重用prepared语句。**最后，这条prepared语句确实不在使用时，调用`sqlite3_finalize`函数释放所有的内部资源和`sqlite3_stmt`数据结构，有效删除prepared语句。

### 预处理Prepare
~~~~C++
int sqlite3_prepare(  
  sqlite3 *db,            /* Database handle */  
  const char *zSql,       /* SQL statement, UTF-8 encoded */  
  int nByte,              /* Maximum length of zSql in bytes. */  
  sqlite3_stmt **ppStmt,  /* OUT: Statement handle */  
  const char **pzTail     /* OUT: Pointer to unused portion of zSql */  
);  
  
int sqlite3_prepare_v2(  
  sqlite3 *db,            /* Database handle */  
  const char *zSql,       /* SQL statement, UTF-8 encoded */  
  int nByte,              /* Maximum length of zSql in bytes. */  
  sqlite3_stmt **ppStmt,  /* OUT: Statement handle */  
  const char **pzTail     /* OUT: Pointer to unused portion of zSql */  
);  
  
int sqlite3_prepare16(  
  sqlite3 *db,            /* Database handle */  
  const void *zSql,       /* SQL statement, UTF-16 encoded */  
  int nByte,              /* Maximum length of zSql in bytes. */  
  sqlite3_stmt **ppStmt,  /* OUT: Statement handle */  
  const void **pzTail     /* OUT: Pointer to unused portion of zSql */  
);  
  
int sqlite3_prepare16_v2(  
  sqlite3 *db,            /* Database handle */  
  const void *zSql,       /* SQL statement, UTF-16 encoded */  
  int nByte,              /* Maximum length of zSql in bytes. */  
  sqlite3_stmt **ppStmt,  /* OUT: Statement handle */  
  const void **pzTail     /* OUT: Pointer to unused portion of zSql */  
);  
~~~~

这些函数的作用是将SQL命令字符串转换为prepared语句。参数db是由sqlite3_open函数返回的指向数据库连接的指针。参数zSql是UTF-8或者UTF-16编码的SQL命令字符串，参数nByte是zSql的字节长度。如果nByte为负值，则prepare函数会自动计算出zSql的字节长度，不过要确保zSql传入的是以NULL结尾的字符串。如果SQL命令字符串中只包含一条SQL语句，那么它没有必要以“;”结尾。参数ppStmt是一个指向指针的指针，用来传回一个指向新建的sqlite3_stmt结构体的指针，sqlite3_stmt结构体里面保存有转换好的SQL语句。如果SQL命令字符串包含多条SQL语句，同时参数pzTail不为NULL，那么它将指向SQL命令字符串中的下一条SQL语句。上面4个函数中的v2版本是加强版，与原始版函数参数相同，不同的是函数内部对于sqlite3_stmt结构体的表现上。细节不去理会，**尽量使用v2版本**。

### 步进（Step）
~~~~C++
int sqlite3_step(sqlite3_stmt*);
~~~~
sqlite3_prepare函数将SQL命令字符串解析并转换为一系列的命令字节码，这些字节码最终被传送到SQlite3的虚拟数据库引擎（VDBE: Virtual Database Engine）中执行，完成这项工作的是sqlite3_step函数。比如一个SELECT查询操作，sqlite3_step函数的每次调用都会返回结果集中的其中一行，直到再没有有效数据行了。每次调用sqlite3_step函数如果返回SQLITE_ROW，代表获得了有效数据行，可以通过sqlite3_column函数提取某列的值。如果调用sqlite3_step函数返回SQLITE_DONE，则代表prepared语句已经执行到终点了，没有有效数据了。很多命令第一次调用sqlite3_step函数就会返回SQLITE_DONE，因为这些SQL命令不会返回数据。对于INSERT，UPDATE，DELETE命令，会返回它们所修改的行号——一个单行单列的值。

### 结果列（Result Columns）
~~~~C++
int sqlite3_column_count(sqlite3_stmt *pStmt);  
~~~~
返回结果集的列数。

~~~~C++
int sqlite3_column_type(sqlite3_stmt*, int iCol); 
~~~~
该函数返回结果集中指定列的本地存储类型，如SQLITE_INTEGER，SQLITE_FLOAT，SQLITE_TEXT，SQLITE_BLOB，SQLITE_NULL。为了获取正确的类型，该函数应该在任何试图提取数据的函数调用之前被调用。SQlite3数据库允许不同类型的数据存储在同一列中，所以对于不同行的相同索引的列调用该函数获取的列类型可能会不同。

比如：
~~~~C++
int sqlite3_column_int(sqlite3_stmt*, int iCol); 
~~~~
从给定列返回一个32位有符号整数，如果该列中包含的整型值无法用32位数值表示，那它将会在没有任何警告的情况下被截断。

我在大作业代码中具体使用的例子如下：

~~~~C++
int exist_in_db(string &city_name)
{
    sqlite3 *db;
    int rc;
    const char* sql;
    string pre_sql;
    
    /* Open database */
    rc = sqlite3_open("The_Map.db", &db);
    if (rc) {
        fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
        exit(0);
    }
    
    pre_sql = "SELECT COUNT(*) FROM ALL_INFO WHERE END = '" + city_name + "';";
    sql = pre_sql.c_str();

    sqlite3_stmt *pstmt;
    sqlite3_prepare(db, sql, (int)strlen(sql), &pstmt, NULL);
    sqlite3_step(pstmt);
    int count=sqlite3_column_int(pstmt,0);
    sqlite3_finalize(pstmt);
    
    if(count > 0)
        return 1;
    
    return 0;
~~~~
这是我自己写的一个函数，用于判断一个具体的值是否存在于某张表中。首先用`sqlite3_stmt`建立一个指向`sqlite3_stmt`类型结构体的指针，prepare sql语句之后用`sqlite3_step`执行，然后用`sqlite3_column_int`返回结果集中第0列的结果（应为指定值在表中的数量）到count变量，如果count不为0说明表中存在指定值，否则不存在。最后用`sqlite3_finalize`函数收尾。
其实整个流程差不多也就是这样，只不过这里没有体现绑定参数的函数，因为没有用到，所以暂时不表。

### sqlite3_exec()
`sqlite3_exec()`是一个封装了`sqlite3_prepare_v2()`, `sqlite3_step()`和 `sqlite3_finalize()`的接口，它的原型如下：

```sql
int sqlite3_exec(
  sqlite3* ppDb,                             /* An open database */
  const char *sql,                           /* SQL to be evaluated */
  int (*callback)(void*,int,char**,char**),  /* Callback function */
  void *,                                    /* 1st argument to callback */
  char **errmsg                              /* Error msg written here */
);
```

第1个参数不再说了，是`sqlite3_open()`函数得到的指针。
第2个参数`const char *sql`是一条sql语句，以\0结尾。
第3个参数`sqlite3_callback`是回调函数，当这条语句执行之后，sqlite3会去调用你提供的这个函数。
第4个参数`void*`是你所提供的指针，你可以传递任何一个指针参数到这里，这个参数最终会传到回调函数里面，如果不需要传递指针给回调函数，可以填NULL。等下我们再看回调函数的写法，以及这个参数的使用。
第5个参数`char** errmsg`是错误信息。注意是指针的指针。sqlite3里面有很多固定的错误信息。执行`sqlite3_exec()`之后，执行失败时可以查阅这个指针（直接`cout<<errmsg`得到一串字符串信息，这串信息告诉你错在什么地方。`sqlite3_exec()`函数通过修改你传入的指针的指针，把你提供的指针指向错误提示信息，这样`sqlite3_exec()`函数外面就可以通过这个`char*`得到具体错误提示。


说明：通常，`sqlite3_callback`和它后面的`void*`这两个位置都可以填NULL。填NULL表示你不需要回调。比如你做insert操作，做delete操作，就没有必要使用回调。而当你做select时，就要使用回调，因为sqlite3把数据查出来，得通过回调告诉你查出了什么数据。

以上的解释都来自网络，下面几节具体说说其中几个重要的参数。

#### const char *sql
如上所说，这个参数是一条sql语句。但它的类型是`const char*`, 而不是方便又好用的`string`类型。如果sql语句中需要有C++/C代码中的变量，用`const char*`就不是很方便处理。我的解决办法是先声明一个`string`类型的`pre_sql`用来预处理sql语句，用它来将变量包含进去。因为如果变量是`string`类型，就可以直接用`string`的加法加进`pre_sql`,而如果不是`stirng`在C++中也可以很方便地转换为`string`类型再进行加法。最后将`pre_sql`利用`c_str()`方法直接赋值给一个`const char*`类型的字符串即可。例子如下：

```C++
const char *sql;

string pre_sql = "SELECT NUMBER, START, END, METHOD, DEPARTURE_TIME, MIN(ARRIVAL_TIME) AS ARRIVAL_TIME, DURATION, PRICE "
        "FROM " + tool + "_INFO "
        "WHERE START = '" + start + "' "
        "AND NUMBER IN "
        "(SELECT NUMBER FROM " + tool + "_INFO "
        "WHERE DEPARTURE_TIME > " + int_to_string(earliest_time) + ") "
        "GROUP BY END; ";
        
        sql = pre_sql.c_str();
```
以上代码中可以看见，`tool`变量和`start`变量因为均为`string`类型变量，可直接 + 到pre_sql语句中去(string类型的加法重载允许这样做，即把两个string连接到一起)，而`earlist_time`变量是`int`型，通过自己定义的`int_to_string`函数可以方便地将其转换为`string`类型并加入。`int_to_string`函数的定义如下：

```C++
//需要包含头文件<sstream>
string int_to_string(int a)
{
    stringstream ss;
    string b;
    ss << a;
    ss >> b;
    return b;
}
```
#### callback函数
这是`sqlite3_exec()`函数中非常非常重要的一个参数，可以用它来获取并保存sql语句处理数据库后的返回值。上面说到如果sql是删除或插入操作时callback函数不是很必要，但当sql是查询操作时，就可以很方便地用calback函数来获取查询的数据并保存在程序的容器中。

*一个重要的点是，sqlite3_exec()函数是每返回一条记录调用一次callback函数。*就是说，如果执行sql语句后sqlite数据库会返回三条记录，那么callback函数就会被重复调用三次。先来看callback函数的原型：

```C++
int callback(void *ptr, int argc, char **argv, char ** azColName);
```
记得`sqlite3_exec()`函数中的空指针`void*`参数吗，这个指针也是为callback函数服务的。先按住不表，来看callback函数的参数。

* 第一个参数即是`sqlite3_exec()`函数参数中的空指针`void*`，执行`sqlite3_exec()`函数时传入这个指针，即会在这里被callback函数调用，作用待会再讲；
* 第二个参数是字段的数量。由于每次调用callback函数返回的是被查到的一条记录，而这条记录有可能会包含多个字段，字段的数量即用这个参数来保存；
* 第三个参数是每个字段的内容。一个`char**`类型，即它是一个`char*`数组。
* 第四个参数是每个字段的名称。同样为`char*`数组。

callback函数的使用例子如下：

```C++
int callback(void *map_ptr, int argc, char **argv, char ** azColName){
    //This function returns only one row of records each time it is called
    
    static int Row_num = 1;
    
    for(int i=0; i<argc; i++) {
        string temp_id(azColName[i]), temp_name(argv[i]);
        (*(map_table *)map_ptr)[Row_num][temp_id] = temp_name;
    }
    Row_num++;
    return 0;
}
```
调用它时，只需：

```C++
sqlite3_exec(db, sql, callback, (void*)map_ptr, &zErrMsg);
```

这是我代码中的函数，对于每个参数的使用应该都清晰明了。在调用`sqlite3_exec()`函数的时候传入了map_ptr指针（强制转换为`void*`，原本指向的是调用`sqlite3_exec()`函数的类中的map容器）,在callback函数中使用时又强制转换为了原来的类型。我用一个嵌套map容器（`map<int, map<string, string>>`）就达到了保存sql语句查询返回的每一条记录的效果。
>注：
>由于`argv`和`azColName`都是`char*`数组，在转换为`string`类型时只有采用声明时赋值的方法比较方便，所以不得不再声明两个`string`类型变量。目前还没有找到更好的办法。

不知道写完了没有，想起了再写吧。
