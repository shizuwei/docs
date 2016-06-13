### 1.vim

#### 1.1 配置文件vim.rc

- 查看配置信息 
  
  	```
	vi --version
	Compiled by root@apple.com
	Normal version without GUI.  Features included (+) or not (-):
	-arabic +autocmd ...
	system vimrc file: "$VIM/vimrc"   --系统配置
	user vimrc file: "$HOME/.vimrc"   --用户配置
	user exrc file: "$HOME/.exrc"
	fall-back for $VIM: "/usr/share/vim"
	```
- 配置文件见文后
	
#### 1.2 cscope+ctags索引文件

cscope可以和ctags联合使用，就像sourceInsight一样使用，但是不用鼠标。

- 检查cscope

	```
	ctags --version
	cscope --version
	```
- 生成符号文件

	```
	#!/bin/sh
	find . -name "*.h" -or -name "*.c"  > cscope.files //要分析的文件
	cscope -bkq -i cscope.files 
	ctags -R
	```
-  可以在vimrc中设置nmap快捷键
   
   ```
	nmap <C-_>s :cs find s <C-R>=expand("<cword>")<CR><CR>
	nmap <C-_>g :cs find g <C-R>=expand("<cword>")<CR><CR>
	nmap <C-_>c :cs find c <C-R>=expand("<cword>")<CR><CR>
	nmap <C-_>t :cs find t <C-R>=expand("<cword>")<CR><CR>
	nmap <C-_>e :cs find e <C-R>=expand("<cword>")<CR><CR>
	nmap <C-_>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
	nmap <C-_>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
	nmap <C-_>d :cs find d <C-R>=expand("<cword>")<CR><CR>
	```
-  常见操作
	
	把光标放到符号上：
	ctags: `CTRL + ]` 跳到定义处， `CTRL + T` 跳回上一处
	在命令模式输入 :cs 可以看到帮助，
	cscope:
	
	```
   c: Find functions calling this function
   d: Find functions called by this function
   e: Find this egrep pattern
   f: Find this file
   g: Find this definition
   i: Find files #including this file
   s: Find this C symbol
   t: Find assignments to
   ``` 
	例如: 使用 `CTRL + _` 再按 `g` 即可查找定义。


### 1.3 系统头文件

例如:Mac OS的系统头文件在 `/usr/include`,那么:

```
ctags -I __THROW --file-scope=yes --langmap=c:+.h --languages=c,c++ --links=yes --c-kinds=+p --fields=+S  -R -f ~/.vim/systags /usr/include /usr/local/include
```
-I 忽略后面的字符串，-R 递归，-f 输出文件名，--c-kinds=+p 为原型生成tag，--langmap=c:+.h .h视为c文件而不是c++文件。

生成了：~/.vim/systags TAG文件。
在.vimrc添加:

```
set tags+=~/.vim/systags
```

cscope,把系统目录include加进去:
find /usr/include/ . -name '*.c' -or -name '*.h'  > cscope.files  

先写到这里。下次补充。
 	
#### 1.3 .vimrc配置文件

下面是Mac OS上的配置：

```
" Configuration file for vim
set modelines=0		" CVE-2007-2438

" Normally we use vim-extensions. If you want true vi-compatibility
" remove change the following statements
" set nocompatible	" Use Vim defaults instead of 100% vi compatibility
set backspace=2		" more powerful backspacing
" 语法高亮
syntax on
" 行号
set nu
" 高亮当前行
set cursorline
hi CursorLine  cterm=NONE   ctermbg=darkred ctermfg=white
hi CursorColumn cterm=NONE ctermbg=darkred ctermfg=white
" c语言风格缩进
set cindent
" 智能缩进
set smartindent
set showmatch
set incsearch
" cscope config
nmap <C-_>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-_>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-_>d :cs find d <C-R>=expand("<cword>")<CR><CR>
set cscopequickfix=s-,c-,d-,i-,t-,e-
cs add cscope.out
set nocp
filetype plugin on 
" mniCppComplete 
let OmniCpp_NamespaceSearch = 1 
let OmniCpp_GlobalScopeSearch = 1 
let OmniCpp_ShowAccess = 1 
let OmniCpp_MayCompleteDot = 1 
let OmniCpp_MayCompleteArrow = 1 
let OmniCpp_MayCompleteScope = 1 
let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"] 

set shiftwidth=4
set ruler
" set tabstop=4
set title
set hlsearch
set smarttab
"set fdm=indent
filetype on
set autoindent
set autochdir
set tags=tags;
set filetype=python
au BufNewFile,BufRead *.py,*.pyw setf python
set autoindent " same level indent
"set autoindent " next level indent
set shiftwidth=4
set softtabstop=4
set cinoptions={0,1s,t0,n-2,p2s,(03s,=.5s,>1s,=1s,:1s
"set ts=4
set expandtab
set nofoldenable
" taglist 配置
let Tlist_Ctags_Cmd='/usr/local/Cellar/ctags/5.8_1/bin/ctags'
let Tlist_Show_One_File=1
let Tlist_Exit_OnlyWindow=1
let Tlist_Use_Right_Window=1


" Don't write backup file if vim is being called by "crontab -e"
au BufWrite /private/tmp/crontab.* set nowritebackup nobackup
" Don't write backup file if vim is being called by "chpass"
au BufWrite /private/etc/pw.* set nowritebackup nobackup

``` 	

