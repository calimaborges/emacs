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

# install magit
cd ~/.config/emacs/site-lisp/magit
make lisp

# install vterm
cd site-lisp/vterm
mkdir -p build
cd build
cmake ..
make

# install projectile
cd site-lisp/projectile
emacs -Q --batch -L . -f batch-byte-compile projectile.el

# install perspective
cd site-lisp/perspective
make

# install persp-projectile
cd site-lisp/persp-projectile
emacs -Q --batch -L . -L ../projectile -L ../perspective -f batch-byte-compile persp-projectile.el

# install mise
emacs -Q --batch -L site-lisp/inheritenv -f batch-byte-compile site-lisp/inheritenv/inheritenv.el
emacs -Q --batch -L site-lisp/inheritenv -L site-lisp/mise -f batch-byte-compile site-lisp/mise/mise.el

# install treesit grammars
emacs --batch -l ~/.config/emacs/init.el -f neoarch-install-ts-grammars

# install hl-todo
cd site-lisp/hl-todo
make

# install wgrep
cd site-lisp/wgrep
emacs -batch -Q -L . -f batch-byte-compile wgrep-ack.el wgrep-ag.el wgrep-deadgrep.el wgrep-helm.el wgrep-pt.el

# install rg
cd site-lisp/rg
emacs -batch -Q -L . -L ../wgrep -f batch-byte-compile *.el
```

### Pull submodules

```
git submodule update --init --recursive
```
