(let ((site-lisp (expand-file-name "site-lisp" user-emacs-directory)))
  (add-to-list 'load-path (expand-file-name "dash" site-lisp))
  (add-to-list 'load-path (expand-file-name "compat" site-lisp))
  (add-to-list 'load-path (expand-file-name "cond-let" site-lisp))
  (add-to-list 'load-path (expand-file-name "llama" site-lisp))
  (add-to-list 'load-path (expand-file-name "with-editor/lisp" site-lisp))
  (add-to-list 'load-path (expand-file-name "transient/lisp" site-lisp))
  (add-to-list 'load-path (expand-file-name "magit/lisp" site-lisp)))

(require 'magit)
(global-set-key (kbd "C-x g") 'magit-status)

(provide 'neoarch-package)
