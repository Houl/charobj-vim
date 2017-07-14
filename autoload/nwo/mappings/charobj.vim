" File:         charobj.vim
" Created:      2017 Jul 04
" Last Change:  2017 Jul 14
" Version:      0.3
" Author:       Andy Wokula <anwoku@yahoo.de>
" License:      Vim License, see :h license

" after autoload\nwo\mappings\nextobj.vim

" Setup:
"   :map <expr> am nwo#mappings#charobj#Plug('a')|nunmap am|sunmap am
"   :map <expr> im nwo#mappings#charobj#Plug('i')|nunmap im|sunmap im
"
" Usage:
"   dam{char}   deletes from {char} to the left (exclusive) to {char} to the
"               right (inclusive), repeatable
"
" Highlights:
" - dot-repetition doesn't ask for input
" - supports digraphs inserted with <C-K>, also when provided by mapping
"       dim<C-K>a:
" Notes:
" - does not move across lines (by intention)
" - extends to start or end of line when there is no match for the character
"   (also when there is no match at all)
" - the "a" motion includes the end character, but excludes the start
"   character
" - the "inner" motion excludes both characters, unless the region is empty
"   (in which case it behaves like the "a" motion)

" There are other solutions:
" - Vim patch by paradigm
"
" - thinca's vim-textobj-between + kana's vim-textobj-user
"   Keys: af{char}, if{char}
"   Pros:
"       o moves across lines
"       o aborts when there is no match
"   Cons: (some just my opinion)
"       o asks for a character when repeating
"       o moves to cmdline when asking for character
"       o [count]af{char} moves [count] steps in both directions (probably
"         desired, but not useful actually)
"       o af{char} should include only one end, not both
"       o starting from Visual mode: moves unpredictably
"

" TODO
" ? move across lines, but: extending a selection with `;' and `,' is nice
"   too
" - detect when f{char} doesn't match

func! nwo#mappings#charobj#Plug(what) "{{{
    return printf("\<Plug>(nwo-charobj-%s)", a:what)
endfunc "}}}

map <Plug>(nwo-charobj-a) <SID>_a-char__
noremap                <SID>_a-char__<Esc> <Esc>
vmap                   <SID>_a-char__<Esc> <Nop>
noremap <expr><silent> <SID>_a-char__      <sid>GetRhs('a', <sid>GetChar())

map <Plug>(nwo-charobj-i) <SID>_i-char__
noremap                <SID>_i-char__<Esc> <Esc>
vmap                   <SID>_i-char__<Esc> <Nop>
noremap <expr><silent> <SID>_i-char__      <sid>GetRhs('i', <sid>GetChar())

func! <sid>GetRhs(ioa, gotcha) "{{{
    "if a:gotcha =~# '["''()<>BW[\]`bpstw{}]'
    "    return a:ioa . a:gotcha
    "else
    return printf(":\<C-U>call nwo#mappings#charobj#Select(%s, %s)\<CR>",
        \ string(a:ioa), string(a:gotcha))
    "endif
endfunc "}}}

func! nwo#mappings#charobj#OldSelect(ioa, char) "{{{
    if a:ioa ==# 'i'
	exec "normal! T". a:char. "v". v:count1. "t". a:char
    elseif a:ioa ==# 'a'
	exec "normal! T". a:char. "v". v:count1. "f". a:char
    endif
endfunc "}}}

" bcol, ecol = positions on matching character
" bcol = position (1-based) one before the start
"        without match: start = 1, one before start = 0
" ecol = (inner motion) one after the end
"        (a motion) on the end
"
" search() is missing a {count} argument

func! nwo#mappings#charobj#Select(ioa, char) "{{{
    let line = getline('.')
    if line == '' || a:char == ''
        return
    endif
    let charpat = nwo#lib#MagicEscape(a:char)
    let blnum = search(charpat, 'b', line('.'))
    let bcol = col('.')

    let cnt = v:count1
    if blnum == 0
        if bcol >= 2
            normal! h
        elseif line =~# '^'. charpat
            let cnt -= 1
            let elnum = line('.')
        endif
    endif

    while cnt >= 1
        let elnum = search(charpat, '', line('.'))
        if elnum == 0
            break
        endif
        let cnt -= 1
    endwhile
    let ecol = col('.')

    if blnum == 0
        let bcol = 0
    endif
    if elnum == 0
        let ecol = col('$')
    endif
    if bcol >= 1
        call cursor('.', bcol)
        normal! lv
    else
        call cursor('.', 1)
        normal! v
    endif
    if ecol - bcol < 10
        if strpart(line, bcol-1, ecol-bcol) !~ '..'
            return
        endif
    endif
    call cursor('.', ecol)
    if elnum == 0 || a:ioa ==# 'i'
        normal! h
    endif
endfunc "}}}

" nwo#am#GetChar1()
func! <sid>GetChar() "{{{
    if getchar(1)
        let chr = getchar()
        if chr == 0
            return chr
        elseif chr == 11
            return s:InputDigraph()
        else
            return nr2char(chr)
        endif
    else
        return ""
    endif
endfunc "}}}

func! s:InputDigraph() "{{{
    let chr1 = nwo#am#GetChar()
    if chr1 ==# "\e"
        return ""
    endif
    let chr2 = nwo#am#GetChar()
    call inputsave()
    call feedkeys("\<C-K>". chr1. chr2. "\r", "n")
    let digchr = input('')
    call inputrestore()
    return digchr
endfunc "}}}

" vim:set et:
