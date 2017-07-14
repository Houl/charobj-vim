" File:         charobj.vim
" Created:      2017 Jul 04
" Last Change:  2017 Jul 14
" Version:      0.3
" Author:       Andy Wokula <anwoku@yahoo.de>
" License:      Vim License, see :h license

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
    return printf(":\<C-U>call nwo#mappings#charobj#Select(%s, %s)\<CR>",
        \ string(a:ioa), string(a:gotcha))
endfunc "}}}

func! nwo#mappings#charobj#OldSelect(ioa, char) "{{{
    if a:ioa ==# 'i'
        exec "normal! T". a:char. "v". v:count1. "t". a:char
    elseif a:ioa ==# 'a'
        exec "normal! T". a:char. "v". v:count1. "f". a:char
    endif
endfunc "}}}

func! nwo#mappings#charobj#Select(ioa, char) "{{{
    let line = getline('.')
    if line == '' || a:char == ''
        return
    endif
    let charpat = '\V'. escape(a:char, '\')
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
    let chr1 = s:BasicGetChar()
    if chr1 ==# "\e"
        return ""
    endif
    let chr2 = s:BasicGetChar()
    call inputsave()
    call feedkeys("\<C-K>". chr1. chr2. "\r", "n")
    let digchr = input('')
    call inputrestore()
    return digchr
endfunc "}}}

func! s:BasicGetChar()
    let chr = getchar()
    return chr != 0 ? nr2char(chr) : chr
endfunc

" vim:set et:
