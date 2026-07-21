;;; neoarch-package.el --- package setup from site-lisp -*- lexical-binding: t; -*-

(defvar neoarch-install-only nil
  "When non-nil, only set up load-path and install helpers; skip package requires.")

(defvar neoarch-byte-compile-warnings nil
  "When non-nil, show byte-compile warnings during `neoarch-install-packages'.")

(when (and neoarch-install-only load-file-name)
  (setq user-emacs-directory
        (file-name-as-directory
         (expand-file-name ".." (file-name-directory load-file-name)))))

(defvar neoarch-site-lisp-dirs
  '("dash" "compat" "cond-let" "llama"
    "with-editor/lisp" "transient/lisp" "magit/lisp"
    "vterm" "projectile" "perspective" "persp-projectile"
    "inheritenv" "mise" "md-ts-mode" "hl-todo"
    "terraform-ts-mode" "wgrep" "rg")
  "Relative directories under site-lisp to add to `load-path' and byte-compile.")
(let ((site-lisp (expand-file-name "site-lisp" user-emacs-directory)))
  (dolist (dir neoarch-site-lisp-dirs)
    (add-to-list 'load-path (expand-file-name dir site-lisp))))

(require 'treesit)
(setq treesit-language-source-alist
      '((markdown . ("https://github.com/tree-sitter-grammars/tree-sitter-markdown" "split_parser" "tree-sitter-markdown/src"))
        (markdown-inline . ("https://github.com/tree-sitter-grammars/tree-sitter-markdown" "split_parser" "tree-sitter-markdown-inline/src"))
        (bash . ("https://github.com/tree-sitter/tree-sitter-bash"))
        (json . ("https://github.com/tree-sitter/tree-sitter-json"))
        (javascript . ("https://github.com/tree-sitter/tree-sitter-javascript" "master" "src"))
        (typescript . ("https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src"))
        (tsx . ("https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src"))
        (python . ("https://github.com/tree-sitter/tree-sitter-python"))
        (yaml . ("https://github.com/tree-sitter-grammars/tree-sitter-yaml"))
        (hcl . ("https://github.com/tree-sitter-grammars/tree-sitter-hcl" "main" "src"))))

(defun neoarch-install-ts-grammars ()
  "Install missing ts grammars."
  (interactive)
  (dolist (lang (mapcar #'car treesit-language-source-alist))
    (unless (treesit-language-available-p lang)
      (message "Installing tree-sitter grammar for: %s" lang)
      (treesit-install-language-grammar lang)))
  (message "All configured tree-sitter grammars are installed!"))

(defun neoarch--site-lisp-absolute (rel)
  "Absolute path for site-lisp subdirectory REL."
  (expand-file-name rel (expand-file-name "site-lisp" user-emacs-directory)))

(defun neoarch--skip-byte-compile-p (file)
  "Return non-nil if FILE should not be byte-compiled."
  (let ((name (file-name-nondirectory file)))
    (or (string-match-p "-autoloads\\.el\\'" name)
        (string-match-p "-tests?\\.el\\'" name)
        (string-match-p "-test-helper\\.el\\'" name)
        (string-match-p "-subtest\\.el\\'" name)
        (member name '("dash-functional.el" "projectile-consult.el")))))

(defun neoarch--clean-elc-dir (rel)
  "Delete existing .elc files in site-lisp subdirectory REL."
  (dolist (elc (directory-files (neoarch--site-lisp-absolute rel) t "\\.elc\\'"))
    (delete-file elc)))

(defun neoarch--byte-compile-site-lisp-dir (rel)
  "Byte-compile Elisp files in site-lisp subdirectory REL."
  (dolist (file (directory-files (neoarch--site-lisp-absolute rel) t "\\`[^.].*\\.el\\'"))
    (unless (neoarch--skip-byte-compile-p file)
      (message "Byte-compiling %s/%s" rel (file-name-nondirectory file))
      (byte-compile-file file))))

(defun neoarch-install-packages ()
  "Byte-compile site-lisp packages and install tree-sitter grammars.

Removes existing .elc files first so compilation does not load stale
bytecode when packages require each other out of dependency order.
Warnings are hidden unless `neoarch-byte-compile-warnings' is non-nil."
  (interactive)
  (require 'bytecomp)
  (let ((load-prefer-newer t)
        (byte-compile-warnings (and neoarch-byte-compile-warnings t))
        (bytecomp--inhibit-lexical-cookie-warning
         (not neoarch-byte-compile-warnings)))
    (dolist (dir neoarch-site-lisp-dirs)
      (neoarch--clean-elc-dir dir))
    (dolist (dir neoarch-site-lisp-dirs)
      (neoarch--byte-compile-site-lisp-dir dir)))
  (neoarch-install-ts-grammars)
  (message "All site-lisp packages compiled!"))

(unless neoarch-install-only
  ;; magit
  (require 'magit)
  (put 'magit-status-mode 'magit-diff-default-arguments
       '("--no-ext-diff"))

  ;; vterm
  (require 'vterm)
  (add-hook 'vterm-mode-hook
            (lambda ()
              (display-line-numbers-mode -1)
              (setq-local global-hl-line-mode nil)
              (when (fboundp 'global-hl-line-unhighlight)
                (global-hl-line-unhighlight))))

  ;; projectile
  (setq projectile-auto-discover t)
  (setq projectile-project-search-path
        '(("~/projects" . 2) "~/neoarch" "~/.config/emacs"))
  (require 'projectile)
  (setq projectile-indexing-method 'hybrid)
  (setq projectile-enable-caching t)
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
          (js-mode         . js-ts-mode)
          (javascript-mode . js-ts-mode)
          (js-json-mode    . json-ts-mode)
          (json-mode       . json-ts-mode)))
  (add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))

  (require 'hl-todo)
  (add-hook 'prog-mode-hook #'hl-todo-mode)

  (require 'terraform-ts-mode)

  (require 'eglot)
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 '(terraform-ts-mode . ("mise" "exec" "--" "terraform-ls" "serve")))
    (add-to-list 'eglot-server-programs
                 '((js-ts-mode typescript-ts-mode tsx-ts-mode)
                   . ("mise" "exec" "--" "tsc" "--lsp" "--stdio"))))
  (dolist (hook '(terraform-ts-mode-hook
                  js-ts-mode-hook
                  typescript-ts-mode-hook
                  tsx-ts-mode-hook))
    (add-hook hook #'eglot-ensure)
    (add-hook hook
              (lambda ()
                (add-hook 'before-save-hook #'eglot-format-buffer nil t))))

  (require 'wgrep)

  (require 'rg))

(provide 'neoarch-package)
