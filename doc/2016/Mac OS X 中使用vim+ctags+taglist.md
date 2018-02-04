## Mac OS X 中使用vim+ctags+taglist

### 1.taglist安装

- 下载 taglist http://www.vim.org/scripts/script.php?script_id=273。文件名：taglist_46.zip
- 创建目录`sudo mkidr ~/taglist`, `cd ~/Downloads`, `sudo unzip taglist_46.zip -d ../taglist`,`cd ../taglist`,拷贝 plugin和doc文件到~/.vim文件夹：`cp -r * ~/.vim`。
- 打开vim,输入命令`:helptags ~/.vim/doc`,然后可以使用`:help taglist-intro`查看taglist的帮助了。

### 2.安装ctags

mac自带的是ctags，而taglist要求的是exuberant ctags。命令: `brew install ctags-exuberant`。之后ctags被安装到`/usr/local/Cellar/ctags/5.8_1/bin/`目录。可以看一下README文件确认一下。
把ctags加入到PATH,这样输入`ctags`才能被识别:

```
echo "export PATH=/usr/local/Cellar/ctags/5.8_1/bin/:$PATH" >> ~/.bash_profile
```

>**小知识:**
>
>　mac和linux终端一般用bash来进行解析。当bash在读完了整体环境变量的/etc/profile并借此调用其他配置文件后，接下来则是会读取用户自定义的个人配置文件。bash读取的文件总共有三种：
>
> ~/.bash_profile 　　~/.bash\_login  　　~/.profile
> 
>　bash启动时按上面的顺序读取配置，一旦读取到其中一个文件就停止读取剩下的文件。

在代码根目录输入`ctags -R`就可以生成tags文件,其中-R表示递归。

### 3.配置

打开vimrc:

```
sudo find / -name vimrc
sudo chmod 666 /usr/share/vim/vimrc
cp /usr/share/vim/vimrc ~/.vimrc
vim ~/.vimrc
```
~/.vimrc只影响本用户,而且会覆盖/usr/share/vim/vimrc中的配置。

vimrc:

```
syntax on 		 "语法高亮
set nu 			 "显示行号
set cindent       "
set smartindent   "智能缩进
set showmatch
set incsearch
set shiftwidth=4
set ruler
set tabstop=4
set title
set smarttab
set fdm=indent  "折叠方式
filetype on
set autoindent
set autochdir
set tags=tags; "tags文件,需要分号

"taglist配置:
let Tlist_Ctags_Cmd='/usr/local/Cellar/ctags/5.8_1/bin/ctags'
let Tlist_Show_One_File=1
let Tlist_Exit_OnlyWindow=1
let Tlist_Use_Right_Window=1
let Tlist_Sort_Type='name'  "按照名称排序
let Tlist_Auto_Open=1 "默认打开

```

> Tips:
> 
> vim中，把光标移到折叠处使用`zc zC zo zO`等命令即可进行展开折叠操作。

在vim中打开taglist:

```
:TlistOpen
```
在右侧会出现taglist窗口。`:TlistClose`关闭窗口。




