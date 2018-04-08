" vim: sw=4  ts=4 et
" Set colorscheme for php files.
if exists('g:a1black_misc_colorscheme_php')
        \ && !empty(g:a1black_misc_colorscheme_php)
        \ && bufnr('$') ==# 1
    silent! execute 'colorscheme ' . g:a1black_misc_colorscheme_php
    set background=dark
endif

" ALE Lint plugin settings.
let b:ale_enabled = 1
let b:ale_max_signs = 30
let b:ale_maximum_file_size = 20480
let b:ale_msg_format = '%s'
let b:ale_echo_msg_format = '%s'
let b:ale_lint = ['php', 'phpstan', 'phpcs']
let b:ale_fixers = ['php_cs_fixer', 'phpcbf']
let b:ale_php_phpstan_level = 4
let b:ale_php_phpcs_standard = 'PSR2'
let b:ale_php_phpcbf_standard = 'PSR2'
" Configure PHP Code Sniffer standard.
let b:bufpath = fnamemodify(a1black#path#fix(bufname('%')), ':p:h')
let b:bufvcs = a1black#path#nearest_dir(b:bufpath, '', '.git', '.svn')
" Configuration file for PHP CodeStandard Fixer.
let b:phpfix = a1black#path#nearest_file(b:bufpath, b:bufvcs, '.php_cs', '.php_cs.dist')
if !empty(b:phpfix)
    let b:ale_php_cs_fixer_options = '--config='.shellescape(fnameescape(b:phpfix))
endif
" Configure standard for PHP Code Sniffer.
let b:phpcs = a1black#path#nearest_file(b:bufpath, b:bufvcs, 'phpcs.xml', 'phpcs.xml.dist')
if !empty(b:phpcs)
    let b:ale_php_phpcs_standard = ''
    let b:ale_php_phpcbf_standard = ''
endif
