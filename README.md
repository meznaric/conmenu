# DON'T USE THIS. IT HAD LESS THAN A DAY OF USAGE

# ConMenu

## Requirements

 - Neovim (tested with v0.5.0)

Optional: if you want some helpers for javascript ecosystem. Specifically for `fromNpm` and `fromLerna`:

 - vim-dispatch - For dispatching jobs in the background
 - jq - For parsing package.json

Optional 2: git-worktree.nvim - This will let you easily create menu from work trees

## Installation

I use Plug as a plugin manager and vimscript for my vim config, here is how I use it:
```
Plug 'meznaric/conmenu'
```

Feel free to open a pull request if you have install instructions for other systems.


## Usage

<details>
  <summary>Simple Menu</summary>
  
  ```
  ToDo
  ```
</details>
<details>
  <summary>Nested Menu</summary>
  
  ```
  ToDo
  ```
</details>
<details>
  <summary>Custom Menu</summary>
  
  ```
  ToDo
  ```
</details>
<details>
  <summary>Filter by filetype / path / mode</summary>
  
  ```
  ToDo
  ```
</details>
<details>
  <summary>package.json scripts menu</summary>
  
  ```
  ToDo
  ```
</details>
<details>
  <summary>lerna scripts menu</summary>

  ```
  ToDo
  ```
</details>
<details>
  <summary>git-worktree.nvim integration</summary>

  Requires git-worktree.nvim to be installed
  ```lua
    -- Prompts for name then uses create_worktree(name, name, origin)
    :lua require('conmenu').createWorktree()

    -- Shows a menu with available work trees, so you can switch easily
    :lua require('conmenu').selectWorktree()

    -- Shows a menu of worktrees ready for removal
    :lua require('conmenu').removeWorktree()
  ```
</details>
<details>
  <summary>Full Reference Configuration</summary>
  
  ```
  ToDo
  ```
</details>

## Configuration

### Basics
 - Default Menu (shown when open() is called)
 - Available Bindings (only these keys will be bound if found in menu item name)

### Visual style 
 - Cursor
 - Highlight groups (background, border, selected, cursor)
 - Borders
 - Icons

# ToDo
 - Figure out how to do anything, not just vim.cmd? Will splitting by input by `:` make sense? And the part before is fed to `vim.fn.feedkeys`?
 - Figure out how to define custom highlight
 - Add onlyModes option
 - Recover selection on quit (so select based actions can work) 

