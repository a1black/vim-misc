" vi: sw=4 ts=4 et

" Delete trailing spaces and empty lines at the end of file.
" Args:
"   bang: Flag to delete empty line at the end of file.
function! a1black#misc#strip_whitespaces(bang)
    let l:state = {}
    let l:msg = ''
    call a1black#state#save(l:state, 'cursor')
    call a1black#state#save_reg(l:state, '/')
    if a:bang
        let l:linecount = line('$')
        silent! execute '%s/\_$\_s*\%$//'
        let l:msg = printf(' and %d line(s) deleted', l:linecount - line('$'))
    endif
    let l:result = execute('%s/\s\+$//e')
    echom printf('%d line(s) changed'.l:msg, str2nr(matchstr(l:result, '\d\+', 0, 1)))
    call a1black#state#restore(l:state)
endfunction

" Copy register content to a file.
" Args:
"   bang: Flag to overwrite file if exists.
"   file: Path to a save file.
"   ...:  List of registers to save.
function! a1black#misc#write_reg(bang, file, ...) abort
    if a:0 ==# 0 || empty(a:file)
        return
    endif
    let l:state = {}
    call a1black#state#save(l:state, 'cursor', 'bufnr')
    let l:filename = fnamemodify(a1black#path#fix(a:file), ':p')
    let l:dirname = fnamemodify(l:filename, ':h')
    try
        if isdirectory(l:filename)
            throw 'Provided path is a directory.'
        elseif !isdirectory(l:dirname)
            call mkdir(l:dirname, 'p')
        endif
        setlocal hidden
        silent! execute 'edit '.l:filename
        setlocal noswapfile modifiable
        if a:bang
            silent! execute '%delete _'
        endif
        for l:bufname in a:000
            let l:last_line = line('$')
            if l:last_line ==# 1 && !strlen(getline(1))
                silent! execute 'normal! "'.l:bufname.'p'
                silent! execute '1delete _'
            else
                silent! execute 'normal! G$"'.l:bufname.'p'
            endif
        endfor
        silent! execute 'write '.l:filename
    catch /^Vim(\w\+):E739/
        echoerr printf('Failed to create directory %s.', l:dirname)
    catch /.*/
        echoerr 'Error writing data to file.'
    finally
        call a1black#state#restore(l:state)
        silent! execute 'bdelete! '.l:filename
    endtry
endfunction
