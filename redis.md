## redis
 
#### 1.安装测试

**下载安装**

下载tar.gz文件[http://redis.io/download](http://redis.io/download),切换目录`cp *.tar.gz /usr/local`，解压`sudo tar -zxf *.tar.gz`, 进入解压后的目录,编译安装`sudo make install`,测试`sudo make test`。

**配置启动**

找到配置文件`vi redis.conf`进行修改.
注意指定日志文件路径：`logfile /usr/local/redis/log-redis.log`,然后使用`tail -f log-redis.log`查看日志。
日志级别`loglevel`可以根据需要设置。
守护模式`daemonize yes`。
`redis.conf`有非常详细的说明，直接阅读即可。
启动服务器：`./redis-server redis.conf`。
启动客户端进行交互：`./redis-cli`。

#### 2.使用jedis操作redis

**添加Maven依赖**：

```
<dependency>
			<groupId>redis.clients</groupId>
			<artifactId>jedis</artifactId>
			<version>2.7.2</version>
</dependency>
```

**直接连接**：

```
Jedis jedis = new Jedis("127.0.0.1", 6379);
```
>注意：直接连接时，jedis对象不能被多个线程同时操作，因此，要在不同线程使用不同对象。但是如果对象太多，同样会出问题。在多线程情况下，考虑使用连接池获取jedis对象，以减少对象数目。

**连接池JedisPool**

创建JedisPool：

```
private static JedisPool pool;
static {
        ResourceBundle bundle = ResourceBundle.getBundle("redis");
        if (bundle == null) {
            throw new IllegalArgumentException("[redis.properties] is not found!");
        }
        JedisPoolConfig config = new JedisPoolConfig();
        config.setMaxIdle(Integer.valueOf(bundle.getString("redis.pool.maxIdle")));
        config.setTestOnBorrow(Boolean.valueOf(bundle.getString("redis.pool.testOnBorrow")));
        config.setTestOnReturn(Boolean.valueOf(bundle.getString("redis.pool.testOnReturn")));
        pool = new JedisPool(config, bundle.getString("redis.ip"), Integer.valueOf(bundle.getString("redis.port")));
    }        
```
连接池配置参数使用properties文件保存：
redis.properties文件：

```
#最大能够保持idel状态的对象数
redis.pool.maxIdle=200
#当调用borrow Object方法时，是否进行有效性检查
redis.pool.testOnBorrow=true
#当调用return Object方法时，是否进行有效性检查
redis.pool.testOnReturn=true
#IP
redis.ip=127.0.0.1
#Port
redis.port=6379
```

从连接池获取jedis对象

```
public static Jedis getJedisFromPool() {
    return pool.getResource();
}
```

把对象返回给连接池：

```
jedis.close();
```

redis操作命令，见[redis官方网站](http://redis.io/commands)。jedis方法名称和redis的操作命令名是相同的。redis的数据都是按照key存储和查询修改的，value支持如下数据类型：

1. string 字符串： ` APPEND GET DEL SET STRLEN DECR/INCR(整数) GETRANGE... `
2. list 列表： ` LPUSH/RPUSH LPOP/RPOP ... `
3. set 无序集合：` SADD SMOVE SPOP SMEMBERS SDIFF...`
4. sorted set有序集合： ` ZADD ZINCRBY ZRANGE...`
5. hashmap 哈希表： ` HDEL HGET HKEYS HLEN HGET ...`

详细操作见官网documentation:[http://redis.io/documentation](http://redis.io/documentation)






 
 