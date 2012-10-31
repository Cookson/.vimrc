" All the default persistent things
" Indentation
set autoindent
set smarttab

" Folding
set foldmethod=syntax
set foldenable
set foldlevelstart=1
let javascript_fold=1

set number
set ruler
set nowrap 
set ignorecase
set mouse=

colorscheme desert

set tabstop=4
set shiftwidth=4

call pathogen#infect()
set keymap=russian-jcukenwin
set iminsert=0
set imsearch=0

:let mapleader=","
let insertJsLog = 1
" Custom common leader commands
nnoremap <leader>sl :SessionList<CR>
nnoremap <leader>ss :SessionSave<CR>
nnoremap <leader>sc :SessionClose<CR>
nnoremap <leader>rr :vsplit $MYVIMRC<CR>
nnoremap <leader>rs :so $MYVIMRC<CR>
nnoremap <space> za
nnoremap <Left> <nop>
nnoremap <Right> <nop>
nnoremap <Up> <nop>
nnoremap <Down> <nop>
nnoremap <c-f> :Grep<Space>
imap <C-Space> <C-X><C-I>
command! W w
" NERDTree mappings
" Focus NERDTree window and enter search mode 
" to type a filename to select.
nnoremap <leader>m <C-w>hgg/
nnoremap <F12> :call NERDTreeTouch()<cr>
nnoremap <C-F12> :NERDTreeClose<CR>
nnoremap <leader>c :call ToggleComments()<cr>
function! NERDTreeTouch()
" Starts NERDTree if it isn't open
" If NERDTree is open, focus it and enter search mode
	if bufexists("NERD_tree_1")
		NERDTreeFocus
		call feedkeys("/")
	else
		NERDTree
	endif
endfunction
function! ToggleComments() 
	execute "normal! ^"
	let curCol=col(".")-1
	let line=getline(".")
	let startLine=line(".")
	let on=1
	if line[curCol]==#"/" && line[curCol+1]==#"/" && line[curCol+2]==#" "
		let add=0
	else
		let add=1
	endif
	if add
		let c=0
		while 1
			execute "normal! i//\ \<Esc>hhj"
			"echom "Current character: >".getline(".")[curCol]."<"
			if getline(".")[curCol] != "\t"
				break
			else
				let c=c+1
			endif
		endwhile
		if c>0
			execute "normal! i//\ \<Esc>"
		endif
		call cursor(startLine, curCol)
	else
		execute "normal! ^"
		let line=getline(".")
		let broken=0
		while line[col(".")-1]==#"/"
			if line(".")==1
				let broken=1
				break
			endif
			execute "normal! k^"
			let line=getline(".")
		endwhile
		if broken == 0
			execute "normal! j^"
		endif
		let line=getline(".")
		while line[col(".")-1]==#"/"
			while line[col(".")-1]==#"/" || line[col(".")-1]==#" "
				execute "normal! x"
				let line=getline(".")
			endw
			execute "normal! j^"
			let line=getline(".")
		endwhile
		call cursor(startLine, curCol)
	endif
endfunction
" Function for proper JavaScript folding
function! JavaScriptFold() 
	setl foldmethod=syntax
	setl foldlevelstart=1
	syn region foldBraces start=/{/ end=/}/ transparent fold keepend extend

	function! JSFold()
		return substitute(getline(v:foldstart), "\t", "    ", "g")
	endfunction
	setl foldtext=JSFold()
endfunction

function! InsertJSDoc()
	execute "normal! i/**\<cr> *\<cr>*/\<esc>k$a \<esc>"
	startinsert!
endfunction

function! InsertJSDocLineStart()
	let prevline=getline(".")
	if match(prevline, "^\\s*\\*[^\\/]")!=-1 || match(prevline, "^\\s*\\*$")!=-1
		execute "normal! a\<cr>* "
	elseif match(prevline, "^\\s*\\/\\*\\*")!=-1
		execute "normal! a\<cr> * "
	else
		execute "normal! a\<cr>s\<c-h>"
	endif
	startinsert
	let pos = getpos(".")
	let pos[2] += 1
	call cursor(pos[1], pos[2])
endfunction
 
function! s:HowManyTabs(lnr)
	return len(matchstr(getline(a:lnr), "^\t*"))
endfunction
function! s:ToEdgeOfBlock(direction)
	let startlnr=line('.')
	let startlinetabs=s:HowManyTabs(startlnr)
	let shift=(a:direction ? 1 : -1)
	let nextlnr=startlnr+shift
	while (s:HowManyTabs(nextlnr)>startlinetabs || len(matchstr(getline(nextlnr), "[^\t ]"))==0) && 1<=nextlnr && nextlnr<=line('$')
		let nextlnr+=shift
	endwhile
	return nextlnr.'gg'
endfunction
function! s:InsertJSBreakpoint(method, defaultText)
	if matchstr(getline("."), "^[ \t]*$") ==# getline(".")
	" If current line is empty
		let lnr = line(".")
		let l = getline(lnr)
		while matchstr(l, "^[ \t]*$") ==# l
			let lnr -= 1
			let l = getline(lnr)
		endwhile
		if len(matchstr(l, "{[ \t]*$")) > 0
			echom "LLL"
			let tabs = repeat("\<Tab>", len(matchstr(getline(lnr), "\t*"))+1)
		else
			echom "KKK"
			let tabs = repeat("\<Tab>", len(matchstr(getline(lnr), "\t*")))
		endif
		execute "normal! 0i" . tabs . a:method . ";\<esc>i"		
	else
		if len(matchstr(getline("."), "{[ \t]*$")) > 0
			let tab = "\t"
		else
			let tab = ""
		endif
		execute "normal! A\<cr>" . tab . a:method. ";\<esc>i"		
	endif
	if a:defaultText==1
		if g:insertJsLog==1
			let text = "\"KAKAKA\""
		elseif g:insertJsLog==2
			let text = "\"KOKOKO\""
		elseif g:insertJsLog==3
			let text = "\"KEKEKE\""
			let g:insertJsLog = 0

		endif
		let g:insertJsLog += 1
		execute "normal! i" . text ."\<esc>$"
	else
		startinsert
	endif
endfunction

function! s:SurroundWithTryCatch()
	execute "normal! gv"
	let startl = line("v")
	let endl = line(".")
	execute "normal! \<esc>" . endl . "ggo} catch (e) {\<cr>\<cr>}\<Esc>"
	execute "normal! " . startl . "ggOtry {\<Esc>"
	while startl+1 <= endl+1
	" Indent selected lines by 1 tab to the right
		execute "normal! " . (startl+1) . "gg>>"
		let startl += 1
	endwhile
	"Insert tabs inside catch (e) {}
	execute "normal! " . (endl+3) . "ggi" . repeat("\<Tab>", s:HowManyTabs(startl))
	call feedkeys("A", "n") " Press A in normal mode
endfunction
inoremap <s-cr> <esc>:call InsertJSDocLineStart()<cr>
au FileType javascript call JavaScriptFold()

" Abbreviations
iabbrev fucntion function
" Autocmds
autocmd VimLeave * NERDTreeClose
autocmd FileType nerdtree nnoremap <buffer> <leader>m <C-w>l
autocmd FileType javascript nnoremap ,jc :call InsertJSDoc()<cr>
autocmd FileType vim setlocal foldmethod=manual
autocmd BufRead *s\ list.txt nnoremap <c-d> yyp
autocmd BufWinLeave *.* mkview
autocmd BufWinEnter *.* silent loadview
nnoremap <leader>l :call <SID>InsertJSBreakpoint('console.log()', 1)<cr>
nnoremap <leader>L :call <SID>InsertJSBreakpoint('console.log()', 0)<cr>
nnoremap <leader>e :call <SID>InsertJSBreakpoint('throw new Error()', 1)<cr>
nnoremap <leader>E :call <SID>InsertJSBreakpoint('throw new Error()', 0)<cr>
vnoremap <leader>t <Esc>:call <SID>SurroundWithTryCatch()<cr>
nnoremap <F2> :w<cr>
inoremap <c-d> <c-o>diw
" Removing shit from GUI so there is more space for everything
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=s
set guioptions-=r
set fdc=0
" Motions
" Inside parenthesis
onoremap p i(


noremap <expr> } <SID>ToEdgeOfBlock(1)
noremap <expr> { <SID>ToEdgeOfBlock(0)
nnoremap <M-o> :b 
