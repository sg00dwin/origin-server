" Some basic vim options to make it work better
set nocompatible          
syntax on                 
filetype on
filetype plugin indent on 

" Set tabbing options
set autoindent
set shiftwidth=2
set softtabstop=2
set expandtab

" Trim trailing whitespace from Ruby and Yaml files
autocmd BufWritePre *.rb,*.yml,*.yaml :%s/\s\+$//e
