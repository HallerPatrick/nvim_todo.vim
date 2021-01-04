# nvim_todo.vim


A neovim plugin that quickl and neatly displays all you todos in your source code.

// TODO: Add screenshot

It uses the [ripgrep](https://github.com/BurntSushi/ripgrep) binary as the backend to search for `TODO` marker in
the code. So make sure to install it.

# Installation

Just do this (with Vim Plug)

```
Plug 'HallerPatrick/nvim_todo.vim'
```

# Usage

Only one command:
```
:TodoList
```

Also always good to map this to a leader

```
nmap <leader>td :TodoList <CR>
```
