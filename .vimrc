" Josh Ziegler's VIM config
" -------------------------------------------------------------------------------------------------

" vim-plug - Package manager
" -------------------------------------------------------------------------------------------------
" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

" Enable package manager (use :PlugUpdate to install or update plugins)
call plug#begin()
  Plug 'itchyny/lightline.vim'             " Improved status and tab line
  Plug 'mengelbrecht/lightline-bufferline' " Add buffer info to lightline
  " Wrapper around the fuzzy finder (fzf)
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  Plug 'junegunn/fzf.vim'
  Plug 'airblade/vim-gitgutter', {'branch': 'main'} " Show git diff in the gutter and (un)stages hunks
  Plug 'scrooloose/nerdtree'              " File tree explorer for vim
  "Plug 'elzr/vim-json'                   " Better JSON highlighting
  Plug 'majutsushi/tagbar'                " Browse tags within code using ctags-exuberant
  Plug 'tomtom/tcomment_vim'              " File-type file commenting and uncommenting
  Plug 'plasticboy/vim-markdown'          " Markdown editing enhancements (folding, links, etc)
  Plug 'farmergreg/vim-lastplace'         " Remember last location with rules for exceptions (git commits, etc)
  Plug 'altercation/vim-colors-solarized' " Solarized colorscheme (light and dark)
  Plug 'yorickpeterse/vim-paper', {'branch': 'main'} " Paper-inspired colorscheme with fewer colors
  Plug 'preservim/vim-pencil'             " Prose-focussed enhancements
  Plug 'preservim/vim-colors-pencil'      " iA Writer inspired colorscheme to go with vim-pencil
  Plug 'kana/vim-textobj-user'            " Required by preservim/vim-textobj-sentence
  Plug 'preservim/vim-textobj-quote'      " Replace quotes (when writing prose)
  Plug 'preservim/vim-textobj-sentence'   " Improves Vim’s native sentence motion command
  Plug 'preservim/vim-wheel'              " Adds movement with Ctrl-J and Ctrl-K
  Plug 'preservim/vim-lexical'            " Building on Vim’s spell-check and thesaurus/dictionary completion
  Plug 'preservim/vim-litecorrect'        " Lightweight auto-correction for Vim
  Plug 'preservim/vim-wordy'              " Highlight jargon, business speak, weasel words, etc.
  Plug 'junegunn/goyo.vim'                " Distraction-free edit mode (like iA Writer)
  if has('nvim')
    Plug 'neovim/nvim-lspconfig'          " Language Server Config Helper
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-treesitter/nvim-treesitter-context'
    " Floating windows and codelens support
    "Plug 'ray-x/guihua.lua', {'do': 'cd lua/fzy && make' }
    Plug 'ray-x/go.nvim'                  " Go support via LSP and TreeSitter
    Plug 'ray-x/navigator.lua'
  endif
call plug#end()

" Basic Settings
" -------------------------------------------------------------------------------------------------
set textwidth=99              " Hard-wrap lines at 99 characters (at word boundaries)
set formatoptions+=cro        " Format comments properly (see manual)
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
set termguicolors             " Enable true color support
filetype on                   " Enables filetype detection
filetype plugin on            " Enables filetype specific plugins
set omnifunc=syntaxcomplete#Complete " Enable auto-completion via Omni
let &colorcolumn="80,100"     " Show a visual line on columns 80, and 100
set omnifunc=syntaxcomplete#Complete " Enable auto-completion via Omni

" Color Scheme
" -------------------------------------------------------------------------------------------------
set background=light          " Set this for the light-version of colorscheme
colorscheme paper             " paper, pencil, solarized, Tango-Custom

" Misc
" -------------------------------------------------------------------------------------------------
autocmd BufWritePre * :%s/\s\+$//e   " Remove all trailing whitespace on file save
if has('nvim')
    set foldmethod=expr
    set foldexpr=nvim_treesitter#foldexpr()
else
    set foldmethod=indent            " Fold based on indent
endif
set foldnestmax=10                   " Deepest fold is 10 levels
set nofoldenable                     " Don't fold by default
if has('nvim')
    set inccommand=split      " Preview :substitute before hitting enter
endif

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
nnoremap <Leader>p :Prose<CR>       " Open in 'prose' mode

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

if has('nvim')
lua <<EOF
-- ray-x/navigator https://github.com/ray-x/navigator.lua
--------------------------------------------------------------------------------------------------
-- require'navigator'.setup()

-- nvim-treesitter https://github.com/nvim-treesitter/nvim-treesitter
--------------------------------------------------------------------------------------------------
require 'nvim-treesitter.configs'.setup({
    ensure_installed = {
        "bash",
        "c",
        "css",
        "comment",
        "dockerfile",
        "go",
        "gomod",
        "gosum",
        "gotmpl",
        "hcl",
        "html",
        "javascript",
        "json",
        "lua",
        "make",
        "scss",
        "sql",
        "ssh_config",
        "tmux",
        "vim",
        "vimdoc",
    },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
})

-- go.nvim
--------------------------------------------------------------------------------------------------
require 'go'.setup({
  goimports = 'gopls', -- if set to 'gopls' will use golsp format
  gofmt = 'gopls', -- if set to gopls will use golsp format
  tag_transform = false,
  test_dir = '',
  comment_placeholder = ' // ...  ',
  lsp_cfg = true, -- false: use your own lspconfig
  lsp_gofumpt = true, -- true: set default gofmt in gopls format to gofumpt
  lsp_on_attach = true, -- use on_attach from go.nvim
  lsp_inlay_hints = {
    enable = true,
    -- hint style, set to 'eol' for end-of-line hints, 'inlay' for inline hints
    -- inlay only avalible for 0.10.x
    style = 'eol',
    -- Note: following setup only works for style = 'eol', you do not need to set it for 'inlay'
    -- Only show inlay hints for the current line
    only_current_line = true,
    parameter_hints_prefix = " ~ ",
  },
  dap_debug = true,
})
local protocol = require'vim.lsp.protocol'
EOF
endif

" Markdown editing
" -------------------------------------------------------------------------------------------------
au! BufRead,BufNewFile *.md set filetype=markdown
" au FileType markdown set wrap

" Goyo
" -------------------------------------------------------------------------------------------------
"  Ensure :q to quit even when Goyo is active
function! s:goyo_enter()
  let b:quitting = 0
  let b:quitting_bang = 0
  autocmd QuitPre <buffer> let b:quitting = 1
  cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!
endfunction

function! s:goyo_leave()
  " Quit Vim if this is the only remaining buffer
  if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
    if b:quitting_bang
      qa!
    else
      qa
    endif
  endif
endfunction

autocmd! User GoyoEnter call <SID>goyo_enter()
autocmd! User GoyoLeave call <SID>goyo_leave()

" Prose
" -------------------------------------------------------------------------------------------------
function! Prose()
  call pencil#init({'wrap': 'soft'})
  call lexical#init()
  call litecorrect#init()
  call textobj#quote#init()
  call textobj#sentence#init()
  Goyo

  let g:pencil#conceallevel = 3     " 0=disable, 1=one char, 2=hide char, 3=hide all (def)
  let g:pencil#conceallevel = 3     " 0=disable, 1=one char, 2=hide char, 3=hide all (def)
  let g:pencil#concealcursor = 'c'  " n=normal, v=visual, i=insert, c=command (def)

  " replace common punctuation
  iabbrev <buffer> -- –
  iabbrev <buffer> --- —
  iabbrev <buffer> << «
  iabbrev <buffer> >> »

  " open most folds
  setlocal foldlevel=6

  " replace typographical quotes (reedes/vim-textobj-quote)
  map <silent> <buffer> <leader>qc <Plug>ReplaceWithCurly
  map <silent> <buffer> <leader>qs <Plug>ReplaceWithStraight

  " highlight words (reedes/vim-wordy)
  noremap <silent> <buffer> <F8> :<C-u>NextWordy<cr>
  xnoremap <silent> <buffer> <F8> :<C-u>NextWordy<cr>
  inoremap <silent> <buffer> <F8> <C-o>:NextWordy<cr>
endfunction

" automatically initialize buffer by file type
autocmd FileType markdown,mkd,text call Prose()
" invoke manually by command for other file types
command! -nargs=0 Prose call Prose()
