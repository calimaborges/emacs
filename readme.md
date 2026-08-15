# emacs

## Prerequisites

### macOS Emacs if you are on macOS

n- https://emacsformacosx.com/

### Mark does not work in macOS

Remember to disable the keymap for changing the keyboard

### Emacs available in the command line to run make for some packages

```bash
sudo ln -s /Applications/Emacs.app/Contents/MacOS/Emacs /usr/local/bin/emacs
```

### Install new submodule

```bash
git submodule add $PACKAGE_REPOSITORY site-lisp/$PACKAGE_NAME
````

- Append a new item to `neoarch-site-lisp-dirs` in `neoarch-package.el`.
- Run the installation script

### Pull submodules

```
git submodule update --init --recursive
```

### Packages

```bash
git clone --recurse-submodules https://github.com/calimaborges/emacs.git ~/.config/emacs

# install vterm (native module)
cd ~/.config/emacs/site-lisp/vterm
mkdir -p build
cd build
cmake ..
make

# byte-compile site-lisp packages and install treesit grammars
emacs -Q --batch --eval "(setq neoarch-install-only t)" \
  -l ~/.config/emacs/lisp/neoarch-package.el \
  -f neoarch-install-packages

# same, but show byte-compile warnings
emacs -Q --batch --eval "(setq neoarch-install-only t neoarch-byte-compile-warnings t)" \
  -l ~/.config/emacs/lisp/neoarch-package.el \
  -f neoarch-install-packages
```

### Eglot

```bash
mise use -g node@latest npm:typescript npm:vscode-langservers-extracted terraform-ls@latest java@26 vfox:tinnet/vfox-jdtls@latest pipx:rassumfrassum
```

