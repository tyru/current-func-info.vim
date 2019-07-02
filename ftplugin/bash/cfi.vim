" vim:foldmethod=marker:fen:
scriptencoding utf-8

runtime! ftplugin/sh/cfi.vim
cfi#register_finder('bash', cfi#get_finder('sh'))
