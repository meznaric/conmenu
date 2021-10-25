fun! ConMenu()
  lua for k in pairs(package.loaded) do if k:match("^conmenu") then package.loaded[k] = nil end end
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
command! -nargs=0 ConMenu :lua require('conmenu').open()
command! -nargs=0 ConMenuNext :lua require('conmenu').switchItem(1)
command! -nargs=0 ConMenuPrevious :lua require('conmenu').switchItem(-1)
command! -nargs=0 ConMenuConfirm :lua require('conmenu').executeItem()
command! -nargs=0 ConMenuClose :lua require('conmenu').close()

augroup ConMenu

  " Default keybindings for when you are in-menu
  autocmd!
  autocmd FileType conmenu nnoremap <silent> <buffer> <CR> :ConMenuConfirm<CR>
  autocmd FileType conmenu nnoremap <silent> <buffer> j :ConMenuNext<CR>
  autocmd FileType conmenu nnoremap <silent> <buffer> <C-n> :ConMenuNext<CR>
  autocmd FileType conmenu nnoremap <silent> <buffer> <C-p> :ConMenuPrevious<CR>
  autocmd FileType conmenu nnoremap <silent> <buffer> k :ConMenuPrevious<CR>
  autocmd FileType conmenu nnoremap <silent> <buffer> q :ConMenuClose<CR>

  " Hide cursor
  autocmd FileType conmenu setlocal guicursor+=a:InvisibleCursor
  " Show cursor
  autocmd BufWipeout,BufHidden,BufLeave conmenu setlocal guicursor-=a:InvisibleCursor

  autocmd BufWipeout,BufHidden,BufLeave conmenu :ConMenuClose

  autocmd ColorScheme * call s:Hi()
augroup END

call s:Hi()
