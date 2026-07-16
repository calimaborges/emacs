;;; neoarch-package.el --- package setup from site-lisp -*- lexical-binding: t; -*-

(let ((site-lisp (expand-file-name "site-lisp" user-emacs-directory)))
  (add-to-list 'load-path (expand-file-name "dash" site-lisp))
  (add-to-list 'load-path (expand-file-name "compat" site-lisp))
  (add-to-list 'load-path (expand-file-name "cond-let" site-lisp))
  (add-to-list 'load-path (expand-file-name "llama" site-lisp))
  (add-to-list 'load-path (expand-file-name "with-editor/lisp" site-lisp))
  (add-to-list 'load-path (expand-file-name "transient/lisp" site-lisp))
  (add-to-list 'load-path (expand-file-name "magit/lisp" site-lisp))
  (add-to-list 'load-path (expand-file-name "vterm" site-lisp))
  (add-to-list 'load-path (expand-file-name "projectile" site-lisp))
  (add-to-list 'load-path (expand-file-name "perspective" site-lisp))
  (add-to-list 'load-path (expand-file-name "persp-projectile" site-lisp))
  (add-to-list 'load-path (expand-file-name "inheritenv" site-lisp))
  (add-to-list 'load-path (expand-file-name "mise" site-lisp))
  (add-to-list 'load-path (expand-file-name "md-ts-mode" site-lisp))
  (add-to-list 'load-path (expand-file-name "hl-todo" site-lisp))
  (add-to-list 'load-path (expand-file-name "terraform-ts-mode" site-lisp))
  (add-to-list 'load-path (expand-file-name "wgrep" site-lisp))
  (add-to-list 'load-path (expand-file-name "rg" site-lisp)))

;; magit
(require 'magit)

;; vterm
(require 'vterm)
(add-hook 'vterm-mode-hook
          (lambda ()
            (display-line-numbers-mode -1)
            ;; global-hl-line redraws on every keystroke and looks like a blink
            (setq-local global-hl-line-mode nil)
            (when (fboundp 'global-hl-line-unhighlight)
              (global-hl-line-unhighlight))))

;; projectile
(setq projectile-auto-discover t)
(setq projectile-project-search-path
      '(("~/projects" . 2) "~/neoarch" "~/.config/emacs"))
(require 'projectile)
(setq projectile-indexing-method 'hybrid)
(dolist (ignore '(".venv" "node_modules"))
  (add-to-list 'projectile-globally-ignored-directories ignore))
(projectile-mode +1)

;; perspective
(custom-set-variables '(persp-suppress-no-prefix-key-warning t))
(require 'perspective)
(persp-mode +1)

;; persp-projectile
(require 'persp-projectile)

;; mise
(require 'mise)
(add-hook 'after-init-hook #'global-mise-mode)

;; md-ts-mode
(autoload 'md-ts-mode "md-ts-mode" "Markdown TS Major mode." t)
(add-to-list 'auto-mode-alist '("\\.md\\'" . md-ts-mode))

;; treesit
(require 'treesit)
(setq treesit-language-source-alist
      '((markdown . ("https://github.com/tree-sitter-grammars/tree-sitter-markdown" "split_parser" "tree-sitter-markdown/src"))
        (markdown-inline . ("https://github.com/tree-sitter-grammars/tree-sitter-markdown" "split_parser" "tree-sitter-markdown-inline/src"))
        (bash . ("https://github.com/tree-sitter/tree-sitter-bash"))
        (json . ("https://github.com/tree-sitter/tree-sitter-json"))
        (python . ("https://github.com/tree-sitter/tree-sitter-python"))
        (yaml . ("https://github.com/tree-sitter-grammars/tree-sitter-yaml"))
        (hcl . ("https://github.com/tree-sitter-grammars/tree-sitter-hcl" "main" "src"))))
(setq treesit-font-lock-level 4)
(with-eval-after-load 'md-ts-mode
  (require 'sh-script)
  (require 'python)
  (require 'json)
  (require 'yaml-ts-mode))
(setq major-mode-remap-alist
      '((sh-mode         . bash-ts-mode)
        (bash-mode       . bash-ts-mode)
        (python-mode     . python-ts-mode)
        (yaml-mode       . yaml-ts-mode)
        (js-json-mode    . json-ts-mode)
        (json-mode       . json-ts-mode)))
(add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-ts-mode))
;; interactive command to compile all grammars
(defun neoarch-install-ts-grammars ()
  "Install missing ts grammars."
  (interactive)
  (dolist (lang (mapcar #'car treesit-language-source-alist))
    (unless (treesit-language-available-p lang)
      (message "Installing tree-sitter grammar for: %s" lang)
      (treesit-install-language-grammar lang)))
  (message "All configured tree-sitter grammars are installed!"))

(require 'hl-todo)
(add-hook 'prog-mode-hook #'hl-todo-mode)

(require 'terraform-ts-mode)

(require 'eglot)
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '(terraform-ts-mode . ("mise" "exec" "--" "terraform-ls" "serve"))))
(add-hook 'terraform-ts-mode-hook #'eglot-ensure)
(add-hook 'terraform-ts-mode-hook
          (lambda ()
            (add-hook 'before-save-hook #'eglot-format-buffer nil t)))

(require 'wgrep)

(require 'rg)

(provide 'neoarch-package)
