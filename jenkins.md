## Debian上安装tomcat和jenkins

### 1.安装tomcat服务器
好记性不如烂笔头。主要是做个记录，以后不知道啥时候可以翻来看看，毕竟是自己写的东西。
直接命令:

```
# apt-get install tomcat7
# cd /etc/tomcat7
# ls
Catalina	     context.xml	 policy.d    tomcat-users.xml
catalina.properties  logging.properties  server.xml  web.xml
# service tomcat7 start
# ps aux|grep tomcat
tomcat7  16863 20.2  9.1 1052852 70212 ?       Sl   18:14   0:02 /usr/lib/jvm/default-java/bin/java -Djava.util.logging.config.file=/var/lib/tomcat7/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djava.awt.headless=true -Xmx128m -XX:+UseConcMarkSweepGC -Djava.endorsed.dirs=/usr/share/tomcat7/endorsed -classpath /usr/share/tomcat7/bin/bootstrap.jar:/usr/share/tomcat7/bin/tomcat-juli.jar -Dcatalina.base=/var/lib/tomcat7 -Dcatalina.home=/usr/share/tomcat7 -Djava.io.tmpdir=/tmp/tomcat7-tomcat7-tmp org.apache.catalina.startup.Bootstrap start

# apt-get install vim
# chmod 666 /usr/share/vim/vimrc
# vi /usr/share/vim/vimrc 把syntax on, set nu打开，好看些
# vi /root/.bashrc 把注释去了，logout一下再登录，ls就有颜色了

# vim server.xml 现在是彩色的了，看一下port
# ip addr|grep inet|grep eth0
    inet 172.26.251.73/24 brd 172.26.251.255 scope global dynamic eth0
```
浏览器访问http://172.26.251.73:8080/。扯远了，其实运行jenkins也可以不用tomcat.
 
### 3.安装jenkins

jenkins介绍：
>Jenkins是基于Java开发的开源的持续集成工具，用于监控持续重复的工作，功能包括：
>
>* 持续的软件版本发布/测试项目。
>* 监控外部调用执行的工作。
jenkins安装时不实用数据库，自身可以直接作为http服务器运行.

至于安装方法，直接看Ubuntu的吧：[jenkins intall](https://wiki.jenkins-ci.org/display/JENKINS/Installing+Jenkins+on+Ubuntu)。安装完毕后，启动服务：sudo /etc/init.d/jenkins start 

注意：
> jenkins可以放在tomcat中启动也可以直接`# java -jar jenkins.war`启动(8080端口)。作为服务启动时，如果端口被占用，可以编辑`/etc/default/jenkins` 更改行HTTP_PORT=8080，修改端口为8081。

```
# service jenkins start
```
访问http://172.26.251.73:8081。即可打开jenkins。可以运行jenkins命令:
```
http://[jenkins-server]/[command]  command := exit|restart|reload| manage...
```
`http://172.26.251.73:8081/manage`可以管理。
可以本地执行命令行操作远程jenkins：
`http://172.26.251.73:8081/cli/`列出了所有命令。

### 4.使用jenkins

参考文档：[使用jenkins](https://wiki.jenkins-ci.org/display/JENKINS/Use+Jenkins)。
Java和非Java项目都可以使用jenkins。
在Web界面http://172.26.251.73:8081下：

1. 选择`新建`可以创建各种项目：
	- 自由风格项目。
	- Maven项目。
2. jenkins项目可以使用源码管理SCM(例如：svn/git),触发器(周期，变化)，build script(例如：maven,shell等)。可以记录结果。也可以通过EMAIL等发送通知。
3. jenkins会定义很多变量，这些变量可以在batch，POM等中使用。
4. 有各种plugin（例如: maven,git）,见[这里](https://wiki.jenkins-ci.org/display/JENKINS/Plugins)。
	- [Git](https://wiki.jenkins-ci.org/display/JENKINS/Git+Plugin) 注意是gitPlugin不是gitClientPlugin,直接输入git plugin过滤,点安装即可。安装完成后，在项目的配置的**源码管理**中可以选择git。
如果用GitHub直接输入：GitHub Plugin即可把git相关依赖都装上。
	- [Maven](https://wiki.jenkins-ci.org/display/JENKINS/Plugins#Plugins-Maven)

### 6.配置

使用github，maven构建。要先安装GitHub Plugin。

- **参数化构建过程:** 可以定义参数比如:branch
- **SCM源码管理:** 
  * 系统管理 >> 系统设置 >> GitHub Plugin Configuration:[上github](https://github.com/settings/tokens)创建personal access token(填上描述信息后，直接生成)，在jenkins中add credentials,填写：kind:secret text, scope:global, secret:粘贴生成的accesstoken, Description:随便写。Add->Verify即可。
  * 选择Git,填写Repository URL：https://github.com/shizuwei/xiaozhaoji，Add用户名密码，源码库浏览器选择githubweb,URL:https://github.com/shizuwei/xiaozhaoji。
- 全局配置：系统设置 -> maven: MAVEN_HOME=/usr/share/maven.到项目中设置一下Maven goal: clean install.

现在jenkins上已经可以构建了。

### 7.配置tomcat支持deploy

`# vi /etc/tomcat7/tomcat-users.xml`添加tomcat用户：

```
<tomcat-users>
   ...
	<role rolename="manager-script"/>
	<user username="tomcat" password="tomcat" roles="manager-script"/>
</tomcat-users>
```
`# vi /etc/maven/setting.xml`添加server：

```
<server>
	<id>tomcat7</id>
	<username>tomcat</username>
	<password>tomcat</password>
</server>
```
pom.xml:

```
修改
```

如果没有安装tomcat7-admin: `# apt-get install tomcat7-admin`,可以打开`http://172.26.251.73:8080/manager/text/list`。
试一下`mvn tomcat7:deploy`
 
### 7.问题
maven运行时报错`tools.jar not found`。

```
# java -version
# apt-get install openjdk-7-jdk
# update-alternatives --config java
```

### 8.更新jenkins

直接下载war，替换即可:

```
# ps aux|grep jenkins
# cd /usr/share/jenkins
# service jenkins stop
# mv jenkins.war jenkins.war.back
# wget http://ftp.tsukuba.wide.ad.jp/software/jenkins/war/1.650/jenkins.war
# service jenkins start
```
