current-func-info.vim
=====================

This Plugin aim to provide the function to get the current function name which your cussor in located at.
It is very useful when the function name is long, you dont have to scroll up to know where you are.

Installation
============

Manual 
------
Copy the files plugin, ftplugin, doc, autoload directories into the related directories on your runtime path.

Using [Vundle](https://github.com/gmarik/vundle)
-------------

1. Add this line in your VundleFile

```
    Bundle "tyru/current-func-info.vim"
```

2. Excute this command in your terminal.


```
	vim +BundleInstall +qall

```

Configuration
=============


Map your shortcut key to echo the current function name on the status bar.

Add this line in your .vimrc file.

```VimL
map <C-g> :call cfi#echo_func_name()<CR>
```

