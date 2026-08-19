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
    "terraform-ts-mode" "neocaml" "ocaml-eglot" "wgrep" "rg" "htmlize"
    "s" "f" "password-store" "password-store-otp" "pass")
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
        (html . ("https://github.com/tree-sitter/tree-sitter-html"))
        (python . ("https://github.com/tree-sitter/tree-sitter-python"))
        (java . ("https://github.com/tree-sitter/tree-sitter-java"))
        (yaml . ("https://github.com/tree-sitter-grammars/tree-sitter-yaml"))
        (hcl . ("https://github.com/tree-sitter-grammars/tree-sitter-hcl" "main" "src"))
        (dockerfile . ("https://github.com/camdencheek/tree-sitter-dockerfile"))
        (ocaml . ("https://github.com/tree-sitter/tree-sitter-ocaml" "v0.25.0-abi14" "grammars/ocaml/src"))
        (ocaml-interface . ("https://github.com/tree-sitter/tree-sitter-ocaml" "v0.25.0-abi14" "grammars/interface/src"))))

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
  (setq persp-sort 'oldest)
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
          (java-mode       . java-ts-mode)
          (yaml-mode       . yaml-ts-mode)
          (js-mode         . js-ts-mode)
          (javascript-mode . js-ts-mode)
          (js-json-mode    . json-ts-mode)
          (json-mode       . json-ts-mode)
          (html-mode       . html-ts-mode)
          (mhtml-mode      . html-ts-mode)))
  (add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . html-ts-mode))
  (add-to-list 'auto-mode-alist
               '("\\(?:Dockerfile\\|Containerfile\\)\\(?:\\..*\\)?\\'\\|\\.[Dd]ockerfile\\'"
                 . dockerfile-ts-mode))

  (require 'hl-todo)
  (add-hook 'prog-mode-hook #'hl-todo-mode)

  (require 'terraform-ts-mode)
  (require 'neocaml)
  (require 'neocaml-dune)
  (require 'neocaml-opam)
  (require 'neocaml-ocamllex)
  (require 'neocaml-menhir)
  (require 'ocaml-eglot)

  (defun neoarch-project-try-java-build (dir)
    "Return a Maven/Gradle project for DIR when a build file is found."
    (when-let ((root (seq-some (lambda (marker)
                                 (locate-dominating-file dir marker))
                               '("pom.xml" "build.gradle" "build.gradle.kts"))))
      (cons 'transient (file-name-as-directory (expand-file-name root)))))

  (defun neoarch-project-try-dune (dir)
    "Return a Dune project for DIR when a dune-project file is found."
    (when-let ((root (locate-dominating-file dir "dune-project")))
      (cons 'transient (file-name-as-directory (expand-file-name root)))))

  (add-hook 'project-find-functions #'neoarch-project-try-java-build)
  (add-hook 'project-find-functions #'neoarch-project-try-dune)

  (defun neoarch-tsserver-js ()
    "Return tsserver.js from a TypeScript 6.x mise install, or nil."
    (let ((dir (expand-file-name
                "npm-typescript/6"
                (expand-file-name ".local/share/mise/installs" (getenv "HOME")))))
      (when (file-directory-p dir)
        (car (directory-files-recursively dir "\\`tsserver\\.js\\'")))))

  (defun neoarch-eglot-typescript-contact (_interactive)
    "Return a typescript-language-server contact with a tsserver fallback."
    (let ((server (executable-find "typescript-language-server"))
          (tsserver (neoarch-tsserver-js)))
      (unless server
        (error "typescript-language-server not found on exec-path"))
      `(,server "--stdio"
                ,@(when tsserver
                    `(:initializationOptions
                      (:tsserver (:fallbackPath ,tsserver)))))))

  (defun neoarch-eglot-jdtls-contact (_interactive &optional project)
    "Return a jdtls contact with a workspace unique to PROJECT's root."
    (let* ((root (expand-file-name
                  (if project (project-root project) default-directory)))
           (jdtls (executable-find "jdtls"))
           (cache (expand-file-name
                   (if (eq system-type 'darwin)
                       "Library/Caches/jdtls"
                     ".cache/jdtls")
                   (getenv "HOME")))
           (data (expand-file-name (concat "jdtls-" (sha1 root)) cache)))
      (unless jdtls
        (error "jdtls not found on exec-path"))
      (list jdtls "-data" data)))

  (defun neoarch-ocamllsp ()
    "Return the absolute path of ocamllsp, or nil."
    (neoarch-opam-apply-env)
    (or (executable-find "ocamllsp")
        (when-let* ((opam (neoarch-opam-executable))
                    (bin (ignore-errors
                           (car (process-lines opam "var" "--readonly" "bin"))))
                    (lsp (expand-file-name "ocamllsp" bin)))
          (and (file-executable-p lsp) lsp))))

  (defun neoarch-eglot-ocaml-contact (_interactive)
    "Return an ocamllsp contact launched inside the current opam switch."
    (let ((opam (neoarch-opam-executable)))
      (unless opam
        (error "opam not found on exec-path"))
      (unless (neoarch-ocamllsp)
        (error "ocamllsp not found; install it with: opam install ocaml-lsp-server"))
      (list opam "exec" "--" "ocamllsp")))

  (require 'eglot)
  (with-eval-after-load 'eglot
    (setq eglot-connect-timeout 60)
    (add-to-list 'eglot-server-programs
                 `((java-mode java-ts-mode) . ,#'neoarch-eglot-jdtls-contact))
    (add-to-list 'eglot-server-programs
                 '(terraform-ts-mode . ("terraform-ls" "serve")))
    (add-to-list 'eglot-server-programs
                 `((js-ts-mode typescript-ts-mode tsx-ts-mode)
                   . ,#'neoarch-eglot-typescript-contact))
    (add-to-list 'eglot-server-programs
                 '(html-ts-mode . ("vscode-html-language-server" "--stdio")))
    (add-to-list 'eglot-server-programs
                 '(json-ts-mode . ("vscode-json-language-server" "--stdio"
                                   :initializationOptions (:provideFormatter t))))
    (add-to-list 'eglot-server-programs
                 `(((neocaml-mode :language-id "ocaml")
                    (neocaml-interface-mode :language-id "ocaml.interface"))
                   . ,#'neoarch-eglot-ocaml-contact)))
  (defun neoarch-java-package-name (&optional file)
    "Return the Java package implied by FILE, or nil."
    (when-let* ((file (or file buffer-file-name))
                (dir (file-name-directory (expand-file-name file)))
                (parts (file-name-split (directory-file-name dir))))
      (catch 'found
        (while parts
          (when (and (equal (nth 0 parts) "src")
                     (nth 1 parts)
                     (equal (nth 2 parts) "java")
                     (nthcdr 3 parts))
            (throw 'found (string-join (nthcdr 3 parts) ".")))
          (setq parts (cdr parts)))
        nil)))

  (defun neoarch-java-insert-package-header ()
    "Insert a package declaration in an empty Java buffer when the path implies one."
    (when (and buffer-file-name (zerop (buffer-size)))
      (when-let ((package (neoarch-java-package-name)))
        (insert "package " package ";\n\n"))))

  (dolist (hook '(terraform-ts-mode-hook
                  js-ts-mode-hook
                  typescript-ts-mode-hook
                  tsx-ts-mode-hook
                  html-ts-mode-hook
                  json-ts-mode-hook
                  java-ts-mode-hook
                  neocaml-base-mode-hook))
    (add-hook hook #'eglot-ensure))
  (add-hook 'java-ts-mode-hook #'neoarch-java-insert-package-header)
  (add-hook 'neocaml-base-mode-hook #'ocaml-eglot-mode)
  (add-hook 'terraform-ts-mode-hook
            (lambda ()
              (add-hook 'before-save-hook #'eglot-format-buffer nil t)))
  (add-hook 'neocaml-base-mode-hook
            (lambda ()
              (setq-local tab-width 2)
              (add-hook 'before-save-hook #'eglot-format-buffer nil t)
              (add-to-list 'eglot-server-programs
                           `(((neocaml-mode :language-id "ocaml")
                              (neocaml-interface-mode :language-id "ocaml.interface"))
                             . ,#'neoarch-eglot-ocaml-contact))))

  (require 'wgrep)

  (require 'rg)

  (autoload 'pass "pass" nil t))

(provide 'neoarch-package)
