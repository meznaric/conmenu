fun! ConMenu()
  " lua for k in pairs(package.loaded) do if k:match("^conmenu") then package.loaded[k] = nil end end
  lua require('conmenu').open()
endfun

function! s:Hi() abort
  " To change the menu colors:
  " highlight default link NormalFloat Normal
  " highlight default link FloatBorder Normal
  highlight default link KeyHighlight WildMenu
  highlight InvisibleCursor gui=reverse blend=100
endfunction

" Commands so you can make your own binds
command! -range -nargs=0 ConMenu :lua require('conmenu').open()
command! -nargs=0 ConMenuNext :lua require('conmenu').switchItem(1)
command! -nargs=0 ConMenuPrevious :lua require('conmenu').switchItem(-1)
command! -nargs=0 ConMenuConfirm :lua require('conmenu').executeItem()
command! -nargs=0 ConMenuClose :lua require('conmenu').close()
command! -nargs=0 ConMenuUpdateRender :lua require('conmenu').updateRender()

augroup ConMenu

  " Default keybindings for when you are in-menu
  autocmd!
  autocmd FileType conmenu nnoremap <silent> <buffer> <ESC> :ConMenuClose<CR>
  autocmd FileType conmenu nnoremap <silent> <buffer> q :ConMenuClose<CR>
  autocmd FileType conmenu nnoremap <silent> <buffer> <CR> :ConMenuConfirm<CR>
  autocmd FileType conmenu map <silent> <buffer> j :ConMenuNext<CR>
  autocmd FileType conmenu nnoremap <silent> <buffer> <C-n> :ConMenuNext<CR>
  autocmd FileType conmenu nnoremap <silent> <buffer> <down> :ConMenuNext<CR>
  autocmd FileType conmenu nnoremap <silent> <buffer> <C-p> :ConMenuPrevious<CR>
  autocmd FileType conmenu map <silent> <buffer> k :ConMenuPrevious<CR>
  autocmd FileType conmenu nnoremap <silent> <buffer> <up> :ConMenuPrevious<CR>

  " Hide cursor
  autocmd FileType conmenu setlocal guicursor+=a:InvisibleCursor
  " Show cursor
  autocmd BufWipeout,BufHidden,BufLeave conmenu setlocal guicursor-=a:InvisibleCursor

  autocmd BufWipeout,BufHidden,BufLeave conmenu :ConMenuClose
  " -- Prevent insert mode
  autocmd InsertEnter conmenu let updaterestore=&updatetime | set updatetime=0
  autocmd InsertLeave conmenu let &updatetime=updaterestore | :ConMenuUpdateRender
  " Scroll back to top (otherwise we can slowly move the cursor down by
  " pressing 'o' multiple times)
  autocmd CursorHoldI conmenu stopinsert | normal! gg
  autocmd ColorScheme * call s:Hi()
augroup END

" Set default variables
let g:conmenu#default_menu = get(g:, 'conmenu#default_menu', [])
let g:conmenu#relative = get(g:, 'conmenu#relative', 'cursor')
let g:conmenu#row = get(g:, 'conmenu#row', 0)
let g:conmenu#col = get(g:, 'conmenu#col', 0)
" Only these keys will be bound if found in menu item name
let g:conmenu#available_bindings = get(g:, 'conmenu#available_bindings',  'wertyuiopasdfghlzxcvbnm')
let g:conmenu#cursor_character = get(g:, 'conmenu#cursor_character',  '>') " ● - You can use a circle if you want?
let g:conmenu#shortcut_highlight_group = get(g:, 'conmenu#shortcut_highlight_group',  'KeyHighlight')
let g:conmenu#borders = get(g:, 'conmenu#borders',  'rounded')

" TODO: Not yet used in lua
let g:conmenu#close_keys = get(g:, 'conmenu#close_keys',  ['q', '<esc>'])
let g:conmenu#js#package_manager = get(g:, 'conmenu#js#package_manager',  'yarn')

call s:Hi()
