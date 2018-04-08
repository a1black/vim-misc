" vi: sw=4 ts=4 et

" Save value of same env states.
" Args:
"   stateobj: Dictionary for storing data.
"   ...:      List of states to save.
function! a1black#state#save(stateobj, ...) abort
    if type(a:stateobj) != type({})
        let a:stateobj = {}
    endif
    for l:state in a:000
        if l:state ==? 'cursor'
            let a:stateobj.cursor = getpos('.')
        elseif l:state ==? 'bufnr'
            let a:stateobj.bufnr = {'id': bufnr('%'), 'name': bufname('%')}
        elseif l:state ==? 'winnr'
            let a:stateobj.winnr = {'id': win_getid(), 'nr': winnr()}
        elseif l:state ==? 'winview'
            let a:stateobj.winview = winsaveview()
        endif
    endfor

    return a:stateobj
endfunction

" Save values of specified registers.
" Args:
"   stateobj: Dictionary for storing data.
"   ...:      List of register names.
function! a1black#state#save_reg(stateobj, ...) abort
    if type(a:stateobj) != type({})
        let a:stateobj = {}
    endif
    if !has_key(a:stateobj, 'regs')
        let a:stateobj.regs = {}
    endif
    for l:regname in a:000
        if type(l:regname) != type('') || strlen(l:regname) != 1
            continue
        endif
        let a:stateobj.regs[l:regname] = {'value': getreg(l:regname), 'type': getregtype(l:regname)}
    endfor

    return a:stateobj
endfunction

" Restore data saved.
" Args:
"   stateobj: Saved env data.
function! a1black#state#restore(stateobj)
    if type(a:stateobj) != type({})
        let a:stateobj = {}
    endif
    " Restore registers.
    if has_key(a:stateobj, 'regs')
        for [l:regname, l:regstate] in items(a:stateobj.regs)
            call setreg(l:regname, l:regstate.value, l:regstate.type)
        endfor
        call remove(a:stateobj, 'regs')
    endif
    " Restore view.
    if has_key(a:stateobj, 'view')
        call winrestview(a:stateobj.view)
        call remove(a:stateobj, 'view')
    endif
    " Restore window ID.
    if has_key(a:stateobj, 'winnr')
        if !win_gotoid(a:stateobj.winnr.id)
            silent! execute winnr('$').'wincmd w'
        endif
        call remove(a:stateobj, 'winnr')
    endif
    " Restore viewpoint onto buffer.
    if has_key(a:stateobj, 'bufnr')
        if bufexists(a:stateobj.bufnr.id)
            silent! execute 'buffer '.a:stateobj.bufnr.id
        endif
        call remove(a:stateobj, 'bufnr')
    endif
    " Restore cursor position.
    if has_key(a:stateobj, 'cursor')
        let a:stateobj.cursor[1] = (a:stateobj.cursor[1] > line('$') ? line('$') : a:stateobj.cursor[1])
        let l:linelen = strlen(getline(a:stateobj.cursor[1]))
        let a:stateobj.cursor[2] = (a:stateobj.cursor[2] > l:linelen ? l:linelen : a:stateobj.cursor[2])
        call setpos('.', a:stateobj.cursor)
        call remove(a:stateobj, 'cursor')
    endif
endfunction
