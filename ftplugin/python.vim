" vim: sw=4 ts=4 et
" General settings.
setlocal autoindent
setlocal smartindent
setlocal expandtab
setlocal shiftround
setlocal shiftwidth=4
setlocal tabstop=4
setlocal textwidth=79
setlocal noshowmatch
setlocal foldmethod=indent
setlocal foldnestmax=2

" SimplyFold settings
let b:SimpylFold_fold_import = 0
" ALE Lint plugin settings.
let b:ale_enabled = 1
let b:ale_echo_msg_format = '%code: %%s (%linter%)'
let b:ale_linters = ['pycodestyle', 'pylint']
let b:ale_fixers = ['autopep8']
" flake8 settings
let g:ale_python_flake8_change_directory = 0
" pylint settings
let g:ale_python_pylint_change_directory = 0
" Locate code standart configuration.
let b:bufpath = fnamemodify(a1black#path#fix(bufname('%')), ':p:h')
let b:bufvcs = a1black#path#nearest_dir(b:bufpath, '', '.git', '.svn')
let b:pep8rc = a1black#path#nearest_file(b:bufpath, b:bufvcs, '.pep8rc')
if !empty(b:pep8rc)
    let b:ale_python_autopep8_options = '--global-config '.shellescape(fnameescape(b:pep8rc))
    let b:ale_python_flake8_options = '--config='.shellescape(fnameescape(b:pep8rc))
    let b:ale_python_pylint_options = '--rcfile '.shellescape(fnameescape(b:pep8rc))
else
    let b:ale_python_pylint_options = '-E'
endif
