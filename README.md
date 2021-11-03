<!-- panvimdoc-ignore-start -->

# ConMenu

Powerful but minimal context menu for neovim.

![Example_1](https://i.imgur.com/VwthRMF.jpg)

<!-- panvimdoc-ignore-end -->

# Features

 - Quick and easy way to build menus & submenus with automatic hotkey bindings
 - Appears next to your cursor (you are probably looking there anyways!)
 - Context based (optionally based on the filetype or custom filter function)
 - Icon unicode support (via dev icons, you need patched fonts)
 - Configure with Vimscript or Lua

Opinionated / optional / language specific features:

 - Helpers for NPM projects and Lerna monorepos
 - Helpers for git worktree workflows

# Requirements

 - Neovim (tested with v0.5.0)

Optional 1/2:
if you want better integration with javascript ecosystem. Specifically for `fromNpm` and `fromLerna`:

 - [vim-dispatch](https://github.com/tpope/vim-dispatch) - For dispatching
   jobs in the background
 - [jq](https://github.com/stedolan/jq) - For parsing package.json
 - yarn - I'll make this configurable at some point so you can use NPM instead

Optional 2/2:
[git-worktree.nvim](https://github.com/ThePrimeagen/git-worktree.nvim) - If you are going to be using `createWorktree`, `selectWorktree`, `removeWorktree`.

<!-- panvimdoc-ignore-start -->

# Installation

I use Plug as a plugin manager and vimscript for my vim config, here is how I use it:
```
Plug 'meznaric/conmenu'
```

Feel free to open a pull request if you have install instructions for other systems.

<!-- panvimdoc-ignore-end -->

# Usage

### Commands
```
" You probably only need this one
:ConMenu
" These commands are used by binds inside a menu
:ConMenuNext
:ConMenuPrevious
:ConMenuConfirm
:ConMenuClose
:ConMenuUpdateRender
```


# Configuration

**Menu**

In the documentation below `Menu` represents the array of `MenuItem`s.

**MenuItem**

Which is defined as an array of 3 items `Name`, `Menu` or `Command`, and `Options`

 - `Name` is the name of the entry in the menu list. What you see.
 - `Menu` or command can be either another array of `MenuItem`s
 - `Options` defines when `MenuListItem` is shown. If you define multiple options
    for example `onlyTypes` and `onlyWorkingDirectories` it will show the menu list
    item only when both conditions are true, *not* when either is true. This is
    optional. Menu items will be always shown if options are not defined.

**Options**

 - `onlyTypes` array of file types
 - `filter` global lua or vimscript function, if it returns true, menu item will be shown
 - `onlyWorkingDirectories` array of path globs. If current working directory
    matches any of the globs then the MenuItem will be shown.
 - `onlyBufferPaths` array of path globs. If current buffer path matches any of the
    globs then the MenuItem will be shown. Empty glob `''`, will match :new buffer.

### Vimscript Reference

```
function! AlwaysShow()
  " Check if in the right folder, or the path is right, or whatever...
  return v:true
endfunction

let s:onlyProjectFolders = [ '/Users/otiv/Projects/*' ]
let s:onlyTsFiles = [ '*.ts' ]
let s:myFileTypes = ['typescript', 'typescriptreact']
let s:myOptions = {
  \ 'onlyTypes': s:myFileTypes,
  \ 'filter': 'AlwaysShow',
  \ 'onlyWorkingDirectories': s:onlyProjectFolders,
  \ 'onlyBufferPaths': s:onlyTsFiles,
  \ }

let s:menuItem = [name, commandOrMenu, s:myOptions]
let s:nestedMenu = [name, [s:menuItem, s:menuItem], s:myOptions]
let s:divider = ['──────────────────────────', v:null, s:myOptions]

let g:conmenu#default_menu = [menuItem, divider, menuItem, nestedMenu]
```

### Lua Reference

```lua
function AlwaysShow()
  -- Check if in the right folder, or the path is right, or whatever...
  return true
end

local options = {
  onlyTypes = { 'typescript', 'typescriptreact' },
  onlyBufferPaths: { path1, path2 },
  onlyWorkingDirectories: { path3, path4 },
  filter = 'AlwaysShow',
}
local menuItem = {name, ":echo hey", options}
local nestedMenu = {name, {menuItem, menuItem}, options}
local divider = {'──────────────────────────', nil, options}

vim.g['conmenu#default_menu'] = { menuItem, divider, menuItem, nestedMenu }
```

## Variables

```vim
" Default menu that opens when you execute ConMenu
let g:conmenu#default_menu = [];

" Only these keys will be bound if found in menu item name
let g:conmenu#available_bindings = '';

" > is the default, but you can use - or something else.
" Note: unicode characters have different width and we do not consider this yet, so shortcut highlights will be off
let g:conmenu#cursor_character = '';

" We use simple Popup Buffer, so NormalFloat and FloatBorder define the colors
" On top of that create a new highlight group shortcut_highlight_group
let g:conmenu#shortcut_highlight_group = 'KeyHighlight';

" This is just passed on to nvim_open_win, here are hte options:
" none, single, double, rounded, solid, shadow
let g:conmenu#border = 'rounded';

" Not yet implemented
let g:conmenu#close_keys = ['q', '<esc>']
let g:conmenu#js#package_manager = 'yarn'
```


## API
```
" Opens default menu (defined at g:conmenu#default_menu)
open()
" Opens custom menu
openCustom(menu)
close()

executeItem()
switchItem(number)

-- Javascript helpers
fromNpm()
fromLerna()

-- Git Worktree helpers
createWorktree()
removeWorktree()
selectWorktree()

-- Used by bindings generated by this script
executeItemNum()
updateRender()
```

# Integrations

## JavaScript integration

Requires [jq](https://github.com/stedolan/jq) so we can parse what scripts there
are in package.json. There is a built in filter `IsInNodeProject`, that you can
use to hide this menu if not inside a node project.

 - Use `fromLerna` to see a list of projects / packages
 - Use `fromNpm` to see a list of available scripts in package.json

### Example
```
let g:conmenu#default_menu = [
  \['Scripts', ":lua require('conmenu').fromNpm()",
    \{ 'filter': 'IsInNodeProject' }],
  \['Lerna Projects', ":lua require('conmenu').fromLerna()",
    \{ 'filter': 'IsInNodeProject' }],
\]
```

## git-worktree.nvim integration


Requires [git-worktree.nvim](https://github.com/ThePrimeagen/git-worktree.nvim).
There are 3 methods for you to use `createWorktree()`, `selectWorktree()` and
`removeWorktree()`. On top of that there is a built in filter "IsInGitWorktree",
that you can use so this menu item is shown only when you are editing inside git repositroy.

### Example
```
let g:conmenu#default_menu = [
  \['Git', [
    \['Status', ':Git'],
    \['Blame', ':Git blame'],
    \['Why', ':GitMessenger'],
    \['────────────────────────────'],
    \['Create Worktree', ":lua require('conmenu').createWorktree()"],
    \['Select Worktree', ":lua require('conmenu').selectWorktree()"],
    \['Remove Worktree', ":lua require('conmenu').removeWorktree()"],
    \], { 'filter': 'IsInGitWorktree' }],
  \]
```
<!-- panvimdoc-ignore-start -->


### Examples

## Simple Menu

- Icons
```
ToDo
```
## Nested Menu

```
ToDo
```
## Custom Menu

```
ToDo
```
## Filter by filetype / path / mode

```
ToDo
```

<!-- panvimdoc-ignore-end -->
