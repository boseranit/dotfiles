# Neovim cheatsheet

`<leader>` and `<localleader>` are `Space`. Pause after `Space` to see
available mappings in which-key. Modes: normal (`N`), insert (`I`), visual
(`V`), and terminal (`T`).

## LSP navigation and actions

These mappings are available when a language server, such as basedpyright or
Ruff, is attached to the buffer.

| Key | Mode | Action |
| --- | --- | --- |
| `gd` | N | Jump to the definition |
| `gD` | N | Jump to the declaration |
| `grr` | N | List all references to the symbol in quickfix |
| `gri` | N | Jump to an implementation |
| `grt` | N | Jump to the type definition |
| `grn` | N | Rename the symbol across the project |
| `gra` | N, V | Show available code actions |
| `K` | N | Show hover documentation and type information |
| `<C-s>` | I | Show signature help |
| `gO` | N | List symbols in the current document's location list |
| `<leader>ws` | N | Search workspace symbols |
| `<leader>f` | N | Format the current buffer |
| `<leader>uh` | N | Toggle inlay hints for the current buffer |

## Diagnostics

| Key | Mode | Action |
| --- | --- | --- |
| `[d` / `]d` | N | Previous / next diagnostic |
| `[D` / `]D` | N | First / last diagnostic in the buffer |
| `<C-w>d` | N | Show the diagnostic under the cursor |
| `<leader>q` | N | Open all diagnostics in the quickfix list |

## Editing

| Key | Mode | Action |
| --- | --- | --- |
| `u` / `<C-r>` | N | Undo / redo |
| `.` | N | Repeat the last change |
| `ciw` / `diw` / `yiw` | N | Change / delete / yank the current word |
| `gcc` | N | Toggle the current line's comment |
| `gc{motion}` / `gc` | N, V | Toggle comments over a motion or selection |
| `>>` / `<<` | N | Indent / unindent the current line |
| `>` / `<` | V | Indent / unindent the selection |
| `=` | N, V | Reindent a motion or selection |
| `J` | N | Join the next line to the current line |
| `[<Space>` / `]<Space>` | N | Add a blank line above / below |

Ordinary yanks use the system clipboard, including through tmux or OSC 52 over
display-less SSH.

## Search and movement

| Key | Mode | Action |
| --- | --- | --- |
| `/` / `?` | N | Search forward / backward |
| `n` / `N` | N | Repeat the search forward / backward |
| `*` / `#` | N, V | Search forward / backward for the word or selection |
| `%` | N | Jump between matching brackets or delimiters |
| `f{char}` / `t{char}` | N | Jump to / just before a character on the line |
| `;` / `,` | N | Repeat the last character jump forward / backward |
| `<C-o>` / `<C-i>` | N | Move backward / forward through the jump list |
| `<C-d>` / `<C-u>` | N | Move down / up half a screen |
| `zz` | N | Centre the current line |
| `:%s/old/new/gc` | Command | Replace throughout the file with confirmation |

## Files and project search

| Key | Mode | Action |
| --- | --- | --- |
| `<C-n>` | N | Open Oil in a floating window |
| `-` | N | Open the parent directory in Oil |
| `gf` | N | Open the file path under the cursor |
| `gx` | N, V | Open the path or URL with the system handler |
| `<leader>ff` | N | Find files, including hidden files |
| `<leader>fg` | N | Search file contents |
| `<leader>fb` | N | Find an open buffer |
| `<leader>fh` | N | Search help tags |

Inside Oil, `<leader>\|` and `<leader>-` open the selection in a vertical or
horizontal split. `<CR>` opens an entry, `<C-p>` previews it, `gr` refreshes,
`g?` shows help, and `<C-c>` closes Oil. Directory entries can be edited like
text; `:w` applies the resulting filesystem operations.

Inside Telescope, `<C-n>` / `<C-p>` move through results and `<CR>` opens one.
Use `<C-x>` / `<C-v>` / `<C-t>` to open in a horizontal split, vertical split,
or tab; `<Tab>` marks results and `<C-q>` sends them to quickfix.

## Panes, buffers, and lists

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>\|` / `<leader>-` | N | Split vertically / horizontally |
| `<C-h/j/k/l>` | N | Move left/down/up/right across Neovim and tmux panes |
| `<M-h/j/k/l>` | N | Resize the pane left/down/up/right |
| `<C-w>c` / `<C-w>o` | N | Close the pane / keep only the current pane |
| `<C-w>=` | N | Equalize pane sizes |
| `<C-w>H/J/K/L` | N | Move the pane to the left/bottom/top/right edge |
| `[b` / `]b` | N | Previous / next buffer |
| `[B` / `]B` | N | First / last buffer |
| `[q` / `]q` | N | Previous / next quickfix item |
| `[Q` / `]Q` | N | First / last quickfix item |
| `[l` / `]l` | N | Previous / next location-list item |
| `[L` / `]L` | N | First / last location-list item |
| `<CR>` | N | Clear search highlighting |
| `<Esc>` | T | Leave terminal mode |

## Git

| Key | Mode | Action |
| --- | --- | --- |
| `[h` / `]h` | N | Previous / next hunk |
| `<leader>gs` | N | Stage hunk |
| `<leader>gr` | N | Reset hunk |
| `<leader>gp` | N | Preview hunk |
| `<leader>gb` | N | Blame current line |
| `<leader>gd` | N | Diff against the index |
| `<leader>gg` | N | Open LazyGit |

## Completion and snippets

| Key | Mode | Action |
| --- | --- | --- |
| `<C-Space>` | I | Open completion or toggle its documentation |
| `<C-e>` | I | Close completion |
| `<C-Up>` / `<C-Down>` | I | Scroll completion documentation |
| `<CR>` | I | Accept the selected completion |
| `<Tab>` / `<S-Tab>` | I | Expand or move forward / backward through snippets and completion |

Custom [C++ snippets](lua/snippets/cpp.lua) and
[LaTeX snippets](lua/snippets/tex.lua) load automatically.

## Markdown

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>lp` | N | Start the live browser preview at `192.168.1.104:5050` |
| `<leader>lq` | N | Close the live browser preview |

## VimTeX

Available when LaTeX support is enabled.

| Key | Action |
| --- | --- |
| `<localleader>ll` | Toggle continuous compilation |
| `<localleader>lv` | Open the PDF at the current location |
| `<localleader>le` | Show compiler errors and warnings |
| `<localleader>lk` | Stop compilation for the current project |
