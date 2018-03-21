" vi: sw=4 ts=4 et

" Save values of specified registers.
" Args:
"   state: Object for storing registers data.
"   ...:   Sequence of register names.
function! s:save_reg_state(state, ...)
    if a:0 > 0 && !has_key(a:state, 'regs') | let a:state.regs = {} | endif
    for l:bufname in a:000
        let a:state.regs[l:bufname] = {'value': getreg(l:bufname), 'type':  getregtype(l:bufname)}
    endfor
endfunction
" Restore previously saved register values.
function! s:restore_reg_state(state)
    if has_key(a:state, 'regs')
        for [l:bufname, l:bufstate] in items(a:state.regs)
            call setreg(l:bufname, l:bufstate.value, l:bufstate.type)
        endfor
        call remove(a:state, 'regs')
    endif
endfunction

" Save cursor position.
function! s:save_cursor_state(state)
    let a:state.cursor = getpos('.')
endfunction
" Move cursor to previously saved position.
function! s:restore_cursor_state(state)
    if has_key(a:state, 'cursor')
        if a:state.cursor[1] > line('$') | let a:state.cursor[1] = line('$') | endif
        let l:length = strlen(getline(a:state.cursor[1]))
        if a:state.cursor[2] > l:length | let a:state.cursor[2] = l:length | endif
        call setpos('.', a:state.cursor)
        call remove(a:state, 'cursor')
    endif
endfunction

" Save name of current buffer.
function! s:save_buffer_state(state)
    let a:state.buffer = {'id': bufnr('%'), 'name': bufname('%')}
endfunction
" Switch viewpoint to saved buffer.
function! s:restore_buffer_state(state)
    if has_key(a:state, 'buffer')
        if bufexists(a:state.buffer.id)
            silent execute 'buffer ' . a:state.buffer.id
        endif
        call remove(a:state, 'buffer')
    endif
endfunction

" Save state of current window.
function! s:save_window_state(state)
    let a:state.window = {'id': win_getid(), 'nr': winnr()}
endfunction
"Goto saved window ID.
function! s:restore_window_state(state)
    if has_key(a:state, 'window')
        if !win_gotoid(a:state.window.id)
            if a:state.window.nr > winnr('$')
                let a:state.window.nr = winnr('$')
            endif
            execute a:state.window.nr . 'wincmd w'
        endif
        call remove(a:state, 'window')
    endif
endfunction

" Delete trailing spaces and empty lines at the end of file.
" Args:
"   bang: flag to delete empty line at the end of file.
function! a1black#misc#strip_whitespaces(bang)
    let l:state = {}
    let l:msg = ''
    call s:save_reg_state(l:state, '/')
    call s:save_cursor_state(l:state)
    if a:bang
        let l:linecount = line('$')
        silent! execute '%s/\_$\_s*\%$//'
        let l:msg = printf(' and %d line(s) deleted', l:linecount - line('$'))
    endif
    let l:result = execute('%s/\s\+$//e')
    echom printf('%d line(s) changed' . l:msg, str2nr(matchstr(l:result, '\d\+', 0, 1)))
    call s:restore_reg_state(l:state)
    call s:restore_cursor_state(l:state)
endfunction

" Copy register content to a file.
" Args:
"   bang: Flag to overwrite file if exists.
"   file: Path to a save file.
"   ...:  List of registers to save.
function! a1black#misc#write_reg(bang, file, ...) abort
    if a:0 ==# 0 | return | endif
    let l:state = {}
    call s:save_cursor_state(state)
    call s:save_buffer_state(state)
    let l:filename = fnamemodify(a:file, ':p')
    let l:dirname = fnamemodify(l:filename, ':h')
    try
        if isdirectory(l:filename)
            throw "Provided path is a directory."
        elseif !isdirectory(l:dirname)
            call mkdir(l:dirname, 'p')
        endif
        setlocal hidden
        silent execute 'edit ' . l:filename
        setlocal noswapfile modifiable
        if a:bang | silent execute '%delete _' | endif
        for l:bufname in a:000
            let l:last_line = line('$')
            if l:last_line ==# 1 && !strlen(getline(1))
                execute 'normal! "' . l:bufname . 'p'
                silent execute '1delete _'
            else
                execute 'normal! G$"' . l:bufname . 'p'
            endif
        endfor
        silent execute 'write ' . l:filename
    catch /^Vim(\w\+):E739/
        echoerr printf("Failed to create directory '%s'.", l:path)
    catch /.*/
        echoerr "Error writing data to file."
    finally
        call s:restore_buffer_state(l:state)
        call s:restore_cursor_state(l:state)
        silent execute 'bdelete! ' . l:filename
    endtry
endfunction

" Toggle quickfix and local list windows.
" Args:
"   type: Window indicator, allowed values ['qf', 'll'].
function! a1black#misc#toggle_location_list(type)
    let l:state = {}
    call s:save_window_state(l:state)
    let l:wprefix = (a:type ==? 'qf' || a:type ==? 'quickfix') ? 'c' : 'l'
    let l:wins = winnr('$')
    silent! execute 'botright ' . l:wprefix . 'window'
    if l:wins ==# winnr('$')
        silent execute l:wprefix . 'close'
        call s:restore_window_state(l:state)
        if l:wins ==# winnr('$')
            echom printf("No positions in %s", l:wprefix ==? 'c' ? 'quickfix' : 'local list')
        endif
    endif
endfunction
