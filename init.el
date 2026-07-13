;;; init.el --- Neoarch Emacs init -*- lexical-binding: t; -*-

;; add the custom 'lisp' directory to Emacs' load path
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'neoarch-customization)
(require 'neoarch-functions)
(require 'neoarch-theme)
(require 'neoarch-package)
(require 'neoarch-keybinding)
