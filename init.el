;; set custom file location and load it
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
    (when (file-exists-p custom-file)
      (load custom-file))

;; disable sound bell
(setq visible-bell t)

;; enables delete-selection-mode to replace marked text on type
(delete-selection-mode 1)

;; theme
(load-theme 'wombat t)

;; add the custom 'lisp' directory to Emacs' load path
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; load your custom architecture code
(require 'neoarch-functions)

;; disable welmcome screen
(setq inhibit-startup-screen t)

;; disable menu bar
(menu-bar-mode -1)

;; disable tool bar
(tool-bar-mode -1)

;; hide scroll bar
(scroll-bar-mode -1)

;; break line visually
(global-visual-line-mode t)

;; display column in the mode line
(column-number-mode 1)

;; highlight current line
(global-hl-line-mode -1)

;; display line number in the left
(global-display-line-numbers-mode 1)

;; discovery (shows keybinding on pause)
(which-key-mode 1)

;; search improvements
(setq isearch-allow-scroll t)
(setq isearch-lazy-count t)
(setq isearch-wrap-pause 'no-ding)

;; improved response to outside events
(setq global-auto-revert-non-file-buffers t)
(global-auto-revert-mode 1)

;; tabs
;; ====
;; Use spaces instead of tabs
(setq-default indent-tabs-mode nil)
;; Set the tab width to 4 spaces
(setq-default tab-width 4)
;; Set the standard indentation level to 4
(setq standard-indent 4)
(add-hook 'c-mode-hook
          (lambda ()
            (setq c-basic-offset 4)
            (c-set-offset 'substatement-open 0)))

;; whitespace highlight
(require 'whitespace)

;; Only show trailing whitespace and highlight tabs
(setq whitespace-style '(face trailing tabs tab-mark))

(global-whitespace-mode 1)

;; auto complete improvements
;; ==========================
(setq-default
 ;; display completion list vertically
 completions-format 'one-column
 ;; display cursor as bar
 cursor-type 'bar)

;; minimalist ui vertical mode
(fido-vertical-mode 1)
(setq icomplete-delay-completions-threshold 4000)

;; configure font
;; use (font-family-list) to list all fonts
;; (font-family-list)
;; (set-face-attribute 'default nil :width 'condensed)
;; (add-to-list 'default-frame-alist '(font . "Iosevka Fixed-14"))
(add-to-list 'default-frame-alist '(font . "FiraCode Nerd Font Mono-13"))
;; (add-to-list 'default-frame-alist '(font . "3270 Nerd Font Mono-16"))
;; (add-to-list 'default-frame-alist '(font . "DepartureMono Nerd Font Mono-14"))

;; org-mode enabled
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

;; compilation mode
;; enables coloring in compilation mode
(ignore-errors
  (require 'ansi-color)
  (defun my/colorize-compilation-buffer ()
    (when (eq major-mode 'compilation-mode)
      (ansi-color-apply-on-region compilation-filter-start (point-max))))
  (add-hook 'compilation-filter-hook 'my/colorize-compilation-buffer))

;; macos tweeks
;; ============
;; fix macos accent for us-altgr-intl
(when (eq system-type 'darwin)
  (setq mac-right-option-modifier 'none))

;; fix macos sentence behavior
(setq sentence-end-double-space t)

;; packages
;; ========

;; initialization
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/")
             '("nongnu" . "https://elpa.nongnu.org/nongnu/"))

;; magit
(use-package magit
  :ensure t
  :config (setq magit-diff-refine-hunk 'all))

;; vterm
(use-package vterm
  :ensure t
  :hook (vterm-mode . (lambda () (display-line-numbers-mode -1))))

;; gptel
(require 'gptel-config)

;; projects
(use-package projectile
  :ensure t
  :bind (:map projectile-mode-map
              ("C-c p" . projectile-command-map))
  :init
  (setq projectile-auto-discover t)
  (setq projectile-project-search-path
        '(;; scans ~/projects/context/<project>
          ("~/projects" . 2)
          ;; explicitly adds neoarch
          "~/neoarch"))
  (projectile-mode +1)
  :config
  ;; use 'hybrid (or 'native) to make Projectile respect the ignore variables below
  (setq projectile-indexing-method 'hybrid)
  (dolist (ignore '(".venv" "node_modules"))
    (add-to-list 'projectile-globally-ignored-directories ignore)))

;; perspective
(use-package perspective
  :ensure t
  :demand t
  :bind
  ("C-x C-b" . persp-list-buffers)         ; or use a nicer switcher, see below
  :custom
  (persp-mode-prefix-key (kbd "C-c M-p"))  ; pick your own prefix key here
  :init
  (persp-mode))

;; perspective projectile
(use-package persp-projectile
  :ensure t
  :after (perspective projectile)
  :bind
  ;; Binds the standard Projectile prefix + 'p' to the persp-projectile command
  (:map projectile-command-map
        ("p" . projectile-persp-switch-project)))

;; mise
(use-package mise
  :ensure t
  :hook (after-init . global-mise-mode))
