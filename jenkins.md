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
浏览器访问http://172.26.251.73:8080/。
 
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
	- [Git](https://wiki.jenkins-ci.org/display/JENKINS/Git+Plugin)


