" VIM color file
"
" Note: Based on the Tango theme for Sublime Text
" by Chris Thomas

hi clear

set background=light
if version > 580
	if exists("syntax_on")
		syntax reset
	endif
endif

set t_Co=256
let g:colors_name="Tango"

hi Character       guifg=#A70000 ctermfg=124  
hi Comment         guifg=#555753 gui=italic ctermfg=240  cterm=italic
hi Constant        guifg=#194A87 ctermfg=24  
hi Cursor          guibg=#000000 ctermbg=00 
hi CursorLine      guibg=#000000     
hi Function        guifg=#5C3566 ctermfg=59  
hi Identifier      guifg=#194A87 ctermfg=24  
hi Keyword         guifg=#303436 gui=bold ctermfg=236  cterm=bold
hi Normal          guifg=#303436 guibg=#EBEAE2   ctermfg=236 ctermbg=254 
hi Number          guifg=#4F9B00 ctermfg=64  
hi Operator        guifg=#687687 ctermfg=66  
hi StorageClass    guifg=#303436 gui=bold ctermfg=236  cterm=bold
hi String          guifg=#A70000 ctermfg=124  
hi Type            guifg=#D15B00 ctermfg=166  
hi Visual          guibg=#4D97FF     
hi ColorColumn     ctermbg=7

hi link Conditional Keyword
hi link Repeat Keyword

hi link cType Keyword


