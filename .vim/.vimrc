filetype on            " enables filetype detection
filetype plugin on     " enables filetype specific plugins

"PEP 8
set expandtab
set tabstop=8
set softtabstop=4
set shiftwidth=4
set autoindent
"set textwidth=79  " I think of short lines as less and less of an issue

"Python code folding
set foldmethod=indent 
nnoremap <space> za
vnoremap <space> zf

"Set our leader to comma
:let mapleader = ","

"NERD Tree Shortcut
map <leader>n :NERDTreeToggle<CR>
" Toggle tag list plugin
map <leader>l :TlistToggle<CR>
"Run aspell on the current file
map <leader>s :!aspell -c % <CR>
"Turn autowrap off
map <leader>o :set textwidth=0 <CR> 
"Turn autowrap on
map <leader>w :set textwidth=79 <CR> 
"Run python
map <leader>p :!python % <CR>

" color settings (if terminal/gui supports it)
if &t_Co > 2 || has("gui_running")
  syntax on          " enable colors
  set hlsearch       " highlight search (very useful!)
  set incsearch      " search incremently (search while typing)
endif

"Misc
"set mouse=a "use mouse in all modes visual mode (not normal,insert,command,help mode
set showmode 
set ignorecase
set ruler 
set nowrap
set smarttab         " smart tab handling for indenting
set smartindent      " smart auto indenting
