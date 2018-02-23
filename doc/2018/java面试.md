# Java面试

## mySQL隔离级别

 ACID，指数据库事务正确执行的四个基本要素的缩写。包含：原子性（Atomicity）、一致性（Consistency）、隔离性（Isolation）、持久性（Durability）。一个支持事务（Transaction）的数据库，必须要具有这四种[特性](https://baike.baidu.com/item/%E7%89%B9%E6%80%A7)，否则在事务过程（Transaction processing）当中无法保证数据的正确性，交易过程极可能达不到交易方的要求。

其中隔离包含四种隔离级别：

READ UNCOMMITTED： (读未提交)：最低级别，任何情况都无法保证。脏读。幻读。不可重复读。

READ COMMITTED： (读已提交)：可避免脏读的发生。幻读。不可重复读。

REPEATABLE READ： (可重复读)：可避免脏读、不可重复读的发生。mySQL默认隔离级别。多版本实现。幻读。

SERIALIZABLE：(串行化)：可避免脏读、不可重复读、幻读的发生。


##  乐观锁 悲观锁

### 乐观锁

针对读多，写少的数据，才用多版本号实现。自己实现。

通常实现是这样的：在表中的数据进行操作时(更新)，先给数据表加一个版本(version)字段，每操作一次，将那条记录的版本号加1。也就是先查询出那条记录，获取出version字段,如果要对那条记录进行操作(更新),则先判断此刻version的值是否与刚刚查询出来时的version的值相等，如果相等，则说明这段期间，没有其他程序对其进行操作，则可以执行更新，将version字段的值加1；如果更新时发现此刻的version值与刚刚获取出来的version的值不相等，则说明这段期间已经有其他程序对其进行操作了，则不进行更新操作。

举例：

下单操作包括3步骤：

1.查询出商品信息

select (status,status,version) from t_goods where id=#{id}

2.根据商品信息生成订单

3.修改商品status为2

update t_goods 

set status=2,version=version+1

where id=#{id} and version=#{version};

根据返回的更新记录个数判断是否成功，不成功再重复进行操作。

hibernate有乐观锁实现。

### 悲观锁

一般是sql数据库提供的。

- 共享锁 SELECT * from city where id = "1" lock in share mode;  多个事物的select都可以共享。没加 lock in share mode的会等待事物提交。

- 排它锁与共享锁相对应，就是指对于多个不同的事务，对同一个资源只能有一把锁。

  与共享锁类似，在需要执行的语句后面加上for update就可以了。

- 行锁（针对有索引的记录）和表锁。




## 多线程

### synchronized关键字

synchronized关键字经过编译之后，会在同步块的前后分别形成monitorenter和monitorexit这两个字节码指令，这两个字节码都需要一个reference类型的参数来指明要锁定和解锁的对象。如果Java程序中的synchronized明确指定了对象参数，那就是这个对象的reference；如果没有明确指定，那就根据synchronized修饰的是实例方法还是类方法，去取对应的对象实例或Class对象来作为锁对象。根据虚拟机规范的要求，在执行monitorenter指令时，首先要尝试获取对象的锁。如果这个对象没被锁定，或者当前线程已经拥有了那个对象的锁，把锁的计数器加1，相应的，在执行monitorexit指令时会将锁计数器减1，当计数器为0时，锁就被释放。如果获取对象锁失败，那当前线程就要阻塞等待，直到对象锁被另外一个线程释放为止。在虚拟机规范对monitorenter和monitorexit的行为描述中，有两点是需要特别注意的。首先，synchronized同步块对同一条线程来说是可重入的，不会出现自己把自己锁死的问题。wait（）和notify（）或notifyAll（）的使用。



### ReentrantLock锁

java.util.concurrent



## JVM调优

#### 垃圾搜集










