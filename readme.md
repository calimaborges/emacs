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

### Pull submodules

```
git submodule update --init --recursive
```
