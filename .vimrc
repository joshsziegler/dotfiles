" Josh Ziegler's VIM config
" -------------------------------------------------------------------------------------------------

" vim-plug - Package manager
" -------------------------------------------------------------------------------------------------
" Enable package manager (use :PlugUpdate to install or update plugins)
call plug#begin()
" Sublime-flavored Monokai color scheme
"Plug 'ErichDonGubler/vim-sublime-monokai'
Plug 'altercation/vim-colors-solarized'
"Plug 'reedes/vim-colors-pencil'
" Improved status and tab line
Plug 'itchyny/lightline.vim'
" Add buffer info to lightline
Plug 'mengelbrecht/lightline-bufferline'
" Wrapper around the fuzzy finder (fzf)
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" Show git diff in the gutter and stages/undoes hunks
Plug 'airblade/vim-gitgutter'
" File tree explorer for vim
Plug 'scrooloose/nerdtree'
" Golang development
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
" Better JSON highlighting
Plug 'elzr/vim-json'
" Browse tags within code using ctags-exuberant
Plug 'majutsushi/tagbar'
" File-type file commenting and uncommenting
Plug 'tomtom/tcomment_vim'
" Markdown editing enhancements (folding, links, etc)
Plug 'plasticboy/vim-markdown'
" Remember last location with rules for exceptions (git commits, etc)
Plug 'farmergreg/vim-lastplace'
call plug#end()

" Basic Settings
" -------------------------------------------------------------------------------------------------
set textwidth=99              " Hard-wrap lines at 99 characters (at word boundaries)
set formatoptions+=cro        " Format comments properly (see manual)
" set nu                        " Show line numbers
set tabstop=4                 " Show existing tabs as 4 spaces
set expandtab                 " When pressing tab, insert 4 spaces
set softtabstop=4             " Make this the same as tabstop
set shiftwidth=4              " When indenting, use 4 spaces
set scrolloff=5               " Number of context lines shown above and below the cursor
set autoindent                " Copy the indentation from the previous line when starting a new line
set showmode                  " Show the current mode
set ignorecase                " Use case-insensitive search
set ruler                     " Show rules on status line (line, column, and virtual column numbers)
set nowrap                    " Disable automatic line-wrapping
set cursorline                " Highlight the line the cursor is on
set incsearch                 " Search incremently (search while typing)
set hlsearch                  " Highlight search
set hidden                    " Allow for hidden buffers, which allows for unsaved buffers
syntax on                     " Enable syntax highlighting
"colorscheme sublimemonokai    "
"colorscheme solarized
colorscheme pencil
set background=light          " Set this for the light-version of colorscheme
filetype on                   " Enables filetype detection
filetype plugin on            " Enables filetype specific plugins
set omnifunc=syntaxcomplete#Complete " Enable auto-completion via Omni
let &colorcolumn="80,100"     " Show a visual line on columns 80, and 100
set foldmethod=indent         " Fold based on indent
set foldnestmax=10            " Deepest fold is 10 levels
set nofoldenable              " Don't fold by default
" let g:go_version_warning = 0  " Stop Vim-Go from complaining about Vim's version
autocmd BufWritePre * :%s/\s\+$//e " Remove all trailing whitespace on file save

" Setup shortcuts
" -------------------------------------------------------------------------------------------------
:let mapleader = ","               " Set the leader to the comma key
map <leader>m :bn <CR>             " Go to the next buffer
map <leader>n :bp <CR>             " Go to the previous buffer
map <leader>b :bd <CR>             " Close the current buffer
map <leader>k :NERDTreeToggle<CR>  " Open/Close NERDTree
map <leader>t :TagbarToggle<CR>    " Open/Close tag viewer
nnoremap <C-J> <C-W><C-J>          " Remap split navigation from Ctrl-w then j to Ctrl-j
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Markdown editing
" -------------------------------------------------------------------------------------------------
au! BufRead,BufNewFile *.md set filetype=markdown
au FileType markdown set wrap

" Lightline - Improved status and tab line
" -------------------------------------------------------------------------------------------------
set noshowmode    " Hide vim's default insert line
set laststatus=2  " Make sure lightline's status line is shown
let g:lightline={}

" Bufferline-Lightline - Add buffer into to Lightline
" -------------------------------------------------------------------------------------------------
set showtabline=2  " Always show the tab line
let g:lightline#bufferline#show_number  = 1
let g:lightline#bufferline#shorten_path = 1
let g:lightline#bufferline#unnamed      = '[No Name]'
let g:lightline.tabline          = {'left': [['buffers']], 'right': [['close']]}
let g:lightline.component_expand = {'buffers': 'lightline#bufferline#buffers'}
let g:lightline.component_type   = {'buffers': 'tabsel'}
autocmd BufWritePost,TextChanged,TextChangedI * call lightline#update()

" vim-gitgutter - Show git diff in the gutter (added/modified/removed)
" -------------------------------------------------------------------------------------------------
set signcolumn=yes  " Always show the git gutter (to avoid moving text)

" NERDTree - File tree explorer
" -------------------------------------------------------------------------------------------------
let NERDTreeQuitOnOpen=1            " Auto-close NERDTree after opening a file

" FZF (fuzzy finder)
" -------------------------------------------------------------------------------------------------
" Use Ctrl-f to search file CONTENTS
map <C-f> :Rg <CR>
" Use Ctrl-p to search file NAMES
nnoremap <C-p> :Files<CR>
" Use RipGrep (rg) command to search file CONTENTS only (not file names)
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --fixed-strings --ignore-case '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'up:60%')
  \           : fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'right:50%:hidden', '?'),
  \   <bang>0)

" vim-go (Golang development)
" -------------------------------------------------------------------------------------------------
" Use goimports on save instead of gofmt (may be slow for larger code bases)
"let g:go_fmt_command = "goimports"

" govim (Golang development)
" -------------------------------------------------------------------------------------------------
"call govim#config#Set("HighlightReferences", 0)
"Use gofumpt to format Go
let g:go_fmt_command="gopls"
let g:go_gopls_gofumpt=1
let g:go_code_completion_enabled = 1
" By default, govim populates the quickfix window with diagnostics reported by
" gopls after a period of inactivity, the time period being defined by
" updatetime (help updatetime). Here we suggest a short updatetime time in
" order that govim/Vim are more responsive/IDE-like
set updatetime=500
" To make govim/Vim more responsive/IDE-like, we suggest a short balloondelay
set balloondelay=250
" Show info for completion candidates in a popup menu
"if has("patch-8.1.1904")
"  set completeopt+=popup
"  set completepopup=align:menu,border:off,highlight:Pmenu
"endif

"set mouse=a
" To get hover working in the terminal we need to set ttymouse.
"
" For the appropriate setting for your terminal. Note that despite the
" automated tests using xterm as the terminal, a setting of ttymouse=xterm
" does not work correctly beyond a certain column number (citation needed)
" hence we use ttymouse=sgr
"set ttymouse=sgr
