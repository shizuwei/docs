#  crawler4j 基础

## 基本信息

1. github地址：https://github.com/yasserg/crawler4j，上面有基本的例子，可以参考。

2. url的存储和去重用的是k-v数据库：[berkeley DB Java版本]: http://mvnrepository.com/artifact/com.sleepycat/je/4.0.92

3. ​每个crawler是一个Runable对象，都会从同一个DB取得和插入url