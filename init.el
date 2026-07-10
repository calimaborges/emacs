;; set custom file location and load it
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
    (when (file-exists-p custom-file)
      (load custom-file))

;; disable sound bell
(setq visible-bell t)

;; enables delete-selection-mode to replace marked text on type
(delete-selection-mode 1)

;; add the custom 'lisp' directory to Emacs' load path
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; load your custom architecture code
(require 'neoarch-functions)

;; theme (defined under lisp/neoarch-theme.el)
(require 'neoarch-theme)

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

(setq-default js-ts-mode-indent-offset 2)
(setq-default typescript-ts-mode-indent-offset 2)

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

(if (eq system-type 'darwin)
    (add-to-list 'default-frame-alist '(font . "FiraCode Nerd Font Mono-12"))
  (add-to-list 'default-frame-alist '(font . "FiraCode Nerd Font Mono-10")))

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

;; packages configuration
(require 'neoarch-package)

;; keybindings
(require 'neoarch-keybinding)
