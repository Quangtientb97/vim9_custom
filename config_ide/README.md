# IDE & Terminal Configurations (`vim_custom/config_ide/`)

This directory archives terminal **color palettes, themes, font settings, and log highlight rules** for **MobaXterm** and **Tabby**, ensuring consistent ANSI color rendering across workstations without carrying local session histories, SSH hostkeys, or environment-specific configurations.

## 1. Directory Structure

```
vim_custom/config_ide/
├── mobaxterm/
│   └── MobaXterm.ini       # Color palette, font, cursor, and dark theme settings
├── tabby/
│   └── config.yaml         # Color schemes (Tian dark mode, Dracula, Atom, VS Code Dark+) & UVM log highlighters
├── tmux/
│   ├── .tmux.conf          # Subdued dark status bar, Vim-like splits, dynamic prefix hints
│   └── tm.py               # Interactive session manager CLI with cheatsheet
└── README.md
```

## 2. Preserved Theme & Color Settings

- **MobaXterm** (`mobaxterm/MobaXterm.ini`):
  - `[Colors]`: 16 ANSI colors, Foreground, Background, Bold, and Cursor colors.
  - `[Font]`: Consolas, size 12, UTF-8.
  - `[Cursor]`: Non-blinking block cursor.
  - `[Misc]`: Windows dark theme preset.
- **Tabby** (`tabby/config.yaml`):
  - `colorScheme`: `Tian dark mode` (custom dark palette).
  - `customColorSchemes`: `Tian dark mode`, `Dracula`, `Atom`, `VS Code Dark+`.
  - `highlightPlugin`: Syntax keywords for EDA simulation logs (`UVM_FATAL`, `UVM_ERROR`, `UVM_WARNING`, `UVM_INFO`).
- **Tmux** (`tmux/.tmux.conf` & `tmux/tm.py`):
  - `.tmux.conf`: Subdued dark status line, Vim-like splits (`<Ctrl-b> v`, `<Ctrl-b> s`), tab management (`<Ctrl-b> c` new tab & rename, `<Ctrl-b> x`), dynamic key hints.
  - `tm.py`: Interactive CLI session manager with one-touch navigation and built-in cheatsheet (`-h`).
