# Custom Vim Configuration (`vim_custom`)

Thư mục cấu hình Vim tùy chỉnh độc lập và di động.

## Cấu trúc thư mục

```
vim_custom/
├── _vimrc          # File cấu hình chính của Vim
├── _vim/           # Thư mục runtime (autoload, custom plugins, filetypes)
│   ├── autoload/
│   │   └── plug.vim
│   └── custom/
│       ├── engineering_tools.vim
│       ├── bottom_terminal.vim
│       ├── cursor_highlight.vim
│       ├── completion_editing.vim
│       ├── which_key.vim
│       ├── doxygen_generator.vim
│       ├── splitjoin.vim
│       ├── smart_selection.vim
│       └── filetypes/
│           ├── verilog_systemverilog.vim
│           ├── python.vim
│           ├── c.vim
│           ├── systemC.vim
│           └── ...
├── vim_env.sh      # Script kích hoạt môi trường cho Bash / Zsh
├── vim_env.csh     # Script kích hoạt môi trường cho Csh / Tcsh
└── README.md
```

## Cách sử dụng

### 1. Cho Bash / Zsh
Chạy lệnh sau trong terminal hoặc thêm vào file `~/.bashrc`:
```bash
source /home/tientq/gemini_vimrc/vim_custom/vim_env.sh
```

### 2. Cho Csh / Tcsh
Chạy lệnh sau trong terminal hoặc thêm vào file `~/.cshrc`:
```csh
source /home/tientq/gemini_vimrc/vim_custom/vim_env.csh
```

### 3. Khởi động Vim
Sau khi source script môi trường:
```bash
vi <filename>
# hoặc
vim <filename>
# hoặc alias chạy trực tiếp:
vic <filename>
```
Vim sẽ tự động nhận diện thư mục runtime `_vim/` và nạp toàn bộ cấu hình, phím tắt, plugin tương ứng.
