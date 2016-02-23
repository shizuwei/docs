## debian-8-jessie docker安装

在Mac上用VirtualBox安装了debian-8-jessie linux发行版。装个docker熟悉一下。因为公司使用docker。

#### 1.安装ssh server
```
$ sudo apt-get install ssh
$ ifconfig      查看server ip地址,本机是172.26.251.73，用户名linux
```
这样在我的Mac上就可以使用

```
$ ssh linux@172.26.251.73 用户名@服务器IP 

```
输入密码,即可以用ssh连上debian-linux,还是Mac的terminal好用些啊.

#### 2. 安装docker容器

安装方法，见官方文档：[docker安装文档](https://docs.docker.com/v1.8/installation/debian/)

命令如下,先使用`su`命令切换到root用户：

```
# vi  /etc/apt/sources.list
```
添加源：deb http://http.debian.net/debian jessie-backports main

```
# apt-get update
# apt-get install docker.io 
# docker run --rm hello-world 成功则会打印相关信息
```

#### 3. 使用docker
docker可以运行指定的镜像Img，镜像可以从Docker Hub[下载](https://hub.docker.com/), Hub上有各种镜像和应用程序下载, 有点像github。

可以搜索你想要的img:

```
# docker search debian
```
下载centos镜像和运行：

```
# docker pull debian
# docker run -t -i debian /bin/bash
root@0b2616b0e5a8:/# ls -l
```
这就可以进入命令行交互模式。使用-d可以作为daemon运行。如果下载的镜像不能满足你的要求，你可以修改它，例如在容器中安装相关软件，然后`docker commit`创建自己的img, 很像git命令吧。

```
# docker commit -m "add something" -a "szw" \
> 0b2616b0e5a8 debian:v2
```
0b2616b0e5a8是我们预先保存的源容器的ID，debian:v2是生成的目标。使用命令可以查看镜像列表:

```
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
debian              v2                  078d83a0ab1a        19 seconds ago      125.1 MB
debian              latest              a0e9fe2f8803        4 days ago          125.1 MB
$ docker run -t -i debian:v2 /bin/bash
```
可以使用`Dockerfile `编写脚本，然后使用`docker build`命令来生成新的镜像。
使用`docker tag 5db5f8471261 debian:devel`可以打tag。
使用`docker push`可以push到Docker Hub。

#### 4.端口和连接
Host可以通过网络端口来访问docker容器。容器里面的ip可以通过`-P`自动绑定到Host的hign port，使用`-p`就可以指定绑定的端口。`docker ps`可以查看绑定的端口。
通过给每个容器取名字，我们可以把容器互联起来，使用`docker run ... --link <name or id>:alias...`命令。见[容器连接](https://docs.docker.com/v1.8/userguide/dockerlinks/)文档。

#### 5.Data Volume
数据卷看上去就相当于是容器中的文件夹，它对应着主机的某个文件夹。
容器启动时，主机文件夹的数据会被拷贝到容器中对应的文件夹。设想把windows主机的src文件夹mount到docker容器的文件夹中，就可以在docker中的linux上测试了。docker允许把主机的单个文件mount到容器。
数据卷可以在容器之间共享，可以合并，备份。相关内容见:[Data Volume](https://docs.docker.com/v1.8/userguide/dockervolumes/)。

#### 6.其它
Windows下只能用Boot2Docker,安装Linux版本的Docker容器.见:[文档](https://docs.docker.com/v1.8/installation/windows/)




