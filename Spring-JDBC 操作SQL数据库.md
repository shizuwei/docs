## Spring-JDBC 操作SQL数据库

#### 1.关于org.springframework.jdbc

Java操作关系数据库，例如MySQL，可以使用数据库对应的JDBC驱动程序(如：mysql-connector-java)提供的的方法。但由于JDBC驱动提供的API使用起来每次都要编写连接、操作、关闭数据库和异常处理的模板（Template）代码，代码显得非常冗长重复，不利于集中精力处理实际问题。

`org.springframework.jdbc`包中提供了经典类JdbcTemplate来简化数据库操作，它实现了`JdbcOperations`接口。其实现是基于callback（回调）来实现的。并且能把JDBC的SQLException转换为更为容易理解的springframework包`org.springframework.dao`中定义的异常类型。

NamedParameterJdbcTemplate包装了JdbcTemplate，提供JdbcTemplate的所有功能，由于增加了命名参数，便于编写和修改sql，使用更为方便。一般都是在xml中定义template的bean然后直接在dao中注入来使用。
 

在spring的application-context.xml配置文件中配置相关beans:

```
<context:property-placeholder location="jdbc.properties"/>

<bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="${jdbc.driverClassName}"/>
        <property name="url" value="${jdbc.url}"/>
        <property name="username" value="${jdbc.username}"/>
        <property name="password" value="${jdbc.password}"/>
</bean>
    
<bean id="namedJdbcTemplate" class="org.springframework.jdbc.core. NamedParameterJdbcTemplate">  
        <property name="dataSource" ref="dataSource" />  
</bean>

```

使用注解注入到DAO的实现类中：

```
@Resource
private NamedParameterJdbcTemplate namedJdbcTemplate;
```

或者使用代码直接创建相关beans:

```
MysqlDataSource dataSource = new MysqlDataSource();
dataSource.setUrl("jdbc:mysql://127.0.0.1:3306/test?useUnicode=true&characterEncoding=utf8");
dataSource.setPassword("123");
dataSource.setUser("mysql");
NamedParameterJdbcTemplate  namedJdbcTemplate = new NamedParameterJdbcTemplate(dataSource);
```

#### 2. NamedParameterJdbcTemplate的接口分析


现在看看template提供的方法：

* excute
	1.  `<T> T execute(String sql, SqlParameterSource paramSource, PreparedStatementCallback<T> action)`
	2.  `<T> T execute(String sql, Map<String, ?> paramMap, PreparedStatementCallback<T> action)`
	3. `<T> T execute(String sql, PreparedStatementCallback<T> action) `
* query
	1. `<T> T query(String sql, SqlParameterSource paramSource, ResultSetExtractor<T> rse)`
	2. `<T> T query(String sql, Map<String, ?> paramMap, ResultSetExtractor<T> rse)`
	3. `<T> T query(String sql, ResultSetExtractor<T> rse)`
	4. `void query(String sql, SqlParameterSource paramSource, RowCallbackHandler rch)`
	5. ` void query(String sql, Map<String, ?> paramMap, RowCallbackHandler rch)`
	6. ` void query(String sql, RowCallbackHandler rch)`
	7. ` <T> List<T> query(String sql, SqlParameterSource paramSource, RowMapper<T> rowMapper)`
	8.  `<T> List<T> query(String sql, Map<String, ?> paramMap, RowMapper<T> rowMapper`
	9.  `<T> List<T> query(String sql, RowMapper<T> rowMapper)`
	10. ` <T> T queryForObject(String sql, SqlParameterSource paramSource, RowMapper<T> rowMapper)`
	11. `<T> T queryForObject(String sql, Map<String, ?> paramMap, RowMapper<T>rowMapper)`
	12. `<T> T queryForObject(String sql, SqlParameterSource paramSource, Class<T> requiredType)`
	13. `<T> T queryForObject(String sql, Map<String, ?> paramMap, Class<T> requiredType)`
	14. `Map<String, Object> queryForMap(String sql, SqlParameterSource paramSource)`
	15. `Map<String, Object> queryForMap(String sql, Map<String, ?> paramMap)`
	16. `<T> List<T> queryForList(String sql, SqlParameterSource paramSource, Class<T> elementType)`
	17. `<T> List<T> queryForList(String sql, Map<String, ?> paramMap, Class<T> elementType)`
	18. `List<Map<String, Object>> queryForList(String sql, SqlParameterSource paramSource)`
	19. `List<Map<String, Object>> queryForList(String sql, Map<String, ?> paramMap)`
	20. `SqlRowSet queryForRowSet(String sql, SqlParameterSource paramSource)`
	21. `SqlRowSet queryForRowSet(String sql, Map<String, ?> paramMap)`
	
* update
	1. `int update(String sql, SqlParameterSource paramSource)`
	2. `int update(String sql, Map<String, ?> paramMap)`
	3. `int update(String sql, SqlParameterSource paramSource, KeyHolder generatedKeyHolder)`
	4. `int update(
			String sql, SqlParameterSource paramSource, KeyHolder generatedKeyHolder, String[] keyColumnNames)`
	5. `int[] batchUpdate(String sql, Map<String, ?>[] batchValues)`
	6. `int[] batchUpdate(String sql, SqlParameterSource[] batchArgs)`
 
查看接口参数很容易发现，所有方法的参数都包含sql，大部分包含param、callback:

| 参数     | 类型和名称     | 说明 |
|:--------|:-------- |:----|
| sql     |`String sql`  |SQL语句|
| param   | `SqlParameterSource paramSource`、`Map<String, ?> paramMap`|SQL语句中的参数|
| callback|`PreparedStatementCallback<T> action`,` ResultSetExtractor<T> rse`,`RowCallbackHandler rch`,`RowMapper<T> rowMapper`,|用于对一行数据进行映射|
| elementType | `Class<T> requiredType` |返回单列数据时，指定数据类型|
| generatedKeyHolder |`KeyHolder generatedKeyHolder`|返回生成的key|

其中，SqlParameterSource 的实现类有：

- MapSqlParameterSource：通过Map构造。
- BeanPropertySqlParameterSource：通过Bean的class构造。

RowMapper的实现类：

- BeanPropertyRowMapper：直接从Bean的class生成mapper。
- ColumnMapRowMapper：直接把ResultSet映射为Map.

最后看一下返回值：

- void: 没有返回值。
- T: query时返回一行数据，excute时T可以是集合类型。
- List<?>, SqlRowSet: 返回多行数据。
- int, int[]: 返回执行一条SQL受影响的行数。

#### 3. 使用示例
使用MySQL,先创建表：

```
CREATE TABLE `user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL DEFAULT '',
  `age` int(10) unsigned DEFAULT NULL,
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `area_id` bigint(20) DEFAULT NULL,
  `mobile` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
```

创建对应的PO(使用lombok简化setter,getter)：

```
@Data
public class User {
    private Long id;
    private String name;
    private Integer age;
    private Date createTime;
    private Long areaId;
    private String mobile;
}
```
##### 3.1 excute使用示例
excute-1,excute-2,excute-3: 注意返回值T可以是集合哦。

```
String sql = "select * from user where id = :id";
Map<String, Object> params = Maps.newHashMap();
params.put("id", 1L);

User user1 = namedJdbcTemplate.execute(sql, new MapSqlParameterSource(params),
    new PreparedStatementCallback<User>() {
    public User doInPreparedStatement(PreparedStatement ps) throws SQLException, DataAccessException {
        ResultSet rs = ps.executeQuery();
        rs.next();
        return buildUser(rs);
    }
});

User user2 = namedJdbcTemplate.execute(sql, params, new PreparedStatementCallback<User>() {
    public User doInPreparedStatement(PreparedStatement ps) throws SQLException, DataAccessException {
        ResultSet rs = ps.executeQuery();
        rs.next();
        return buildUser(rs);
    }
});

List<User> users = namedJdbcTemplate.execute("select * from user", new PreparedStatementCallback<List<User>>() {
    @Override
    public List<User> doInPreparedStatement(PreparedStatement ps) throws SQLException, DataAccessException {
        ResultSet rs = ps.executeQuery();
        List<User> users = Lists.newArrayList();
        while (rs.next()) {
            users.add(buildUser(rs));
        }
        return users;
    }
});

```

如果excute不需要任何参数，也不返回值，怎么办呢？ 可以返回namedJdbcTemplate内部的jdbcTemplate，它有相应的方法：

```
  String sql = "create table mytable (id integer, name varchar(100))";
  namedJdbcTemplate.getJdbcOperations().execute(sql);
```

##### 3.2 query使用示例
Sql语句和参数：

```
String sql = "select * from user where id >= :id";
Map<String, Object> paramMap = Maps.newHashMap();
paramMap.put("id", 1);
```
query-1~3：用于返回整个结果集，在excute上简单封装。1,2和3只有参数的区别，只举例3：

```
List<User> list = 
namedJdbcTemplate.query(sql, new ResultSetExtractor<List<User>>() {
    @Override
    public List<User> extractData(ResultSet rs) throws SQLException, DataAccessException {
        List<User> users = Lists.newArrayList();
        while (rs.next()) {
            users.add(buildUser(rs));
        }
        return users;
    }
});
```
query-4~6类似,都是用RowCallbackHandler，只用处理一行即可。举例6:

```
 List<User> list = 
    namedParameterJdbcTemplate.query(sql, new RowCallbackHandler() {
        @Override
        public void processRow(ResultSet rs) throws SQLException {
            users.add(buildUser(rs));
        }
    });
```
query-7~9类似,都是用RowMapper，只用处理一行即可,注意：可以获取到rowNum。举例9:

```
 List<User> list = 
	 namedJdbcTemplate.query(sql, new RowMapper<User>() {
	    @Override
	    public User mapRow(ResultSet rs, int rowNum) throws SQLException {
	        return buildUser(rs);
	    }
	});
```

query-10~15，作用一样，都是返回一行数据，只是参数和返回值类型不一样而已，注意11，12的requiredType参数，
当使用11，12时，sql只能返回简单的一列数据,例如(`select count(*) from user`）,否则报错,查看源码其内部是调用query-10实现，并且使用的是`SingleColumnRowMapper`,只支持一列数据。
query-10:使用BeanPropertySqlParameterSource, BeanPropertyRowMapper可极大简化编码。

> 两者都是用了反射实现映射。BeanPropertyRowMapper支持直接映射或者驼峰(camel),即: sql语句中的name直接映射到User类中的name, area_id映射到areaId。
> BeanPropertySqlParameterSource则要求User类中的参数和sql中的冒号后的参数一致：areaId 对应 :areaId。

```
User user = new User();
user.setId(1L);
List<User> listUser =
namedParameterJdbcTemplate.query("select * from user where id = :id", 
		new BeanPropertySqlParameterSource(user4), new BeanPropertyRowMapper<User>(User.class)
	);
```

query-11: 只能返回基本数据。

```
try {
    List<User> users10 =
        namedParameterJdbcTemplate.queryForList(sql, new BeanPropertySqlParameterSource(user4), User.class);
} catch (org.springframework.jdbc.IncorrectResultSetColumnCountException e) {
    e.printStackTrace();
    // 注意此处会发生异常,只允许返回一列数据，所以只能用来返回基本数据，比如Integer,String,Long等的List，见SingleColumnRowMapper
}
// 只能用来返回基本数据
Integer count2 =
    namedParameterJdbcTemplate.queryForObject("select count(1) from user where id = :id", paramMap,
        Integer.class);
List<Long> ids =
    namedParameterJdbcTemplate.queryForList(sql, new BeanPropertySqlParameterSource(user4), Long.class);
// 由此可见，queryForList只能用来返回基本数据哦
```

##### 3.2 update使用示例
update-1~2比较简单，传入相应参数和sql即可返回影响的数据行数。略过。用于UPDATE,INSERT语句。
INSERT时如果设定了自动生成主键ID,update-3~4可以返回ID值。update-3用于一个自动生成ID，update-4可以用于多个，需要指定key的名称。

update-3:

```
String sql = "insert into user (name,age,area_id,mobile) values (:name,:age,:areaId,:mobile)";
User user = new User();
user.setAge(11);
user.setAreaId(110L);
user.setMobile("15997666334");
user.setName("cookies");
GeneratedKeyHolder generatedKeyHolder = new GeneratedKeyHolder();// 获取自动生成的id
int count =
    namedParameterJdbcTemplate.update(sql, new BeanPropertySqlParameterSource(user), generatedKeyHolder);
logger.debug("count = {}, key = {}", count, generatedKeyHolder.getKey());
```

update-5~6: batch update，批量操作，两个方法类似:

```
String sql = "insert into user (name,age,area_id,mobile) values (:name,:age,:areaId,:mobile)";
@SuppressWarnings("rawtypes")
Map[] batchValues = new HashMap[10];
for (int i = 0; i < batchValues.length; i++) {
    Map v = new HashMap();
    batchValues[i] = v;
    batchValues[i].put("name", "哈哈" + i);
    batchValues[i].put("age", 11 + i);
    batchValues[i].put("areaId", 123 + i);
    batchValues[i].put("mobile", "1867297999" + i);
}
// update-4:
int[] c1 = namedParameterJdbcTemplate.batchUpdate(sql, batchValues);
logger.debug("counts = {}", counts);

// update-5:
SqlParameterSource[] batchArgs = new SqlParameterSource[10];
for (int i = 0; i < batchArgs; i++) {
    User user = new User();
    user.setAge(11 + i);
    user.setAreaId(110L + i);
    user.setMobile("1599766633" + i);
    user.setName("cookies" + i);
    batchArgs[i] = new BeanPropertySqlParameterSource(user);
}
int[] c2 = namedParameterJdbcTemplate.batchUpdate(sql, batchArgs);
logger.debug("counts = {}", c2);
```

---
**参考**

[1.Data access with JDBC](http://docs.spring.io/spring/docs/current/spring-framework-reference/html/jdbc.html#jdbc-introduction)













