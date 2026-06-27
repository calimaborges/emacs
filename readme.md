# emacs

## Prerequisites

### macOS Emacs if you are on macOS

- https://emacsformacosx.com/


### Emacs available in the command line to run make for some packages

```bash
sudo ln -s /Applications/Emacs.app/Contents/MacOS/Emacs /usr/local/bin/emacs
```

### Packages

```bash
git clone --recurse-submodules https://github.com/calimaborges/emacs.git ~/.config/emacs
cd ~/.config/emacs/site-lisp/magit && make lisp
```