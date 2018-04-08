" vi: sw=4 ts=4 et

" Simplify provided path.
function! a1black#path#fix(path) abort
    if has('unix')
        let l:res = substitute(simplify(a:path), '^//\+', '/', 'g')
    else
        let l:res = substitute(a:path, '/', '\\', 'g')
        let l:res = substitute(simplify(l:res), '^\\\+', '\', 'g')
    endif

    return l:res
endfunction

" Find first nearest file by searching upwards.
" Args:
"   path: Search start directory.
"   stop: Search stop directory.
"   ...:  List of files to be searched.
function! a1black#path#nearest_file(path, stop, ...) abort
    if empty(a:path)
        throw 'Search path is not provided.'
    elseif !empty(a:stop)
        let l:stop = fnamemodify(a1black#path#fix(a:stop), ':p')
        let l:stop = fnameescape(l:stop)
    else
        let l:stop = a:stop
    endif
    let l:start = fnamemodify(a1black#path#fix(a:path), ':p')
    let l:start = fnameescape(l:start)
    for l:fname in a:000
        let l:fdir = findfile(l:fname, l:start.';'.l:stop)
        if !empty(l:fdir)
            return fnamemodify(l:fdir, ':p')
        endif
    endfor

    return ''
endfunction

" Find first nearest directory by searching upwards.
" Args:
"   path: Search start point.
"   stop: Search stop point.
"   ...:  List of directories to be searched.
function! a1black#path#nearest_dir(path, stop, ...) abort
    if empty(a:path)
        throw 'Search path is not provided.'
    elseif !empty(a:stop)
        let l:stop = fnamemodify(a1black#path#fix(a:stop), ':p')
        let l:stop = fnameescape(l:stop)
    else
        let l:stop = a:stop
    endif
    let l:start = fnamemodify(a1black#path#fix(a:path), ':p')
    let l:start = fnameescape(l:start)
    for l:search in a:000
        let l:fdir = finddir(l:search, l:start.';'.l:stop)
        if !empty(l:fdir)
            return fnamemodify(l:fdir, ':p')
        endif
    endfor

    return ''
endfunction
