" Josh Ziegler's VIM config
" -------------------------------------------------------------------------------------------------

" vim-plug - Package manager 
" -------------------------------------------------------------------------------------------------
" Enable package manager (use :PlugUpdate to install or update plugins)
call plug#begin()           
" Sublime-flavored Monokai color scheme
Plug 'ErichDonGubler/vim-sublime-monokai'
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
call plug#end()


" Basic Settings 
" -------------------------------------------------------------------------------------------------
set nu                        " Show line numbers
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
colorscheme sublimemonokai    " 
filetype on                   " Enables filetype detection
filetype plugin on            " Enables filetype specific plugins
let g:go_version_warning = 0  " Stop Vim-Go from complaining about Vim's version
let &colorcolumn="80,100"     " Show a visual line on columns 80, and 100 
:let mapleader = ","          " Set the leader to the comma key
autocmd BufWritePre * :%s/\s+$//e " Remove all trailing whitespace on file save
" Go to next/previous buffer
map <C-Up> :bn <CR> 
map <C-Down> :bp <CR>
" Close the current buffer
map <C-w> :bd <CR>


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


" NERDTree - File tree explorer
" -------------------------------------------------------------------------------------------------
map <C-k><C-b> :NERDTreeToggle<CR>  " Open/Close NERDTree with Ctrl-k-b
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
  \   'rg --column --line-number --no-heading --color=always --fixed-strings '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'up:60%')
  \           : fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'right:50%:hidden', '?'),
  \   <bang>0)


" vim-go (Golang development)
" -------------------------------------------------------------------------------------------------
" Use goimports on save instead of gofmt (may be slow for larger code bases)
let g:go_fmt_command = "goimports"

