;;; neoarch-customization.el --- UI and behavior tweaks -*- lexical-binding: t; -*-

;; set custom file location and load it
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
    (when (file-exists-p custom-file)
      (load custom-file))

;; disable backup files
(setq make-backup-files nil)

;; keep auto-save files out of project directories
(let ((auto-save-dir (expand-file-name "auto-save/" user-emacs-directory)))
  (unless (file-directory-p auto-save-dir)
    (make-directory auto-save-dir t))
  (setq auto-save-file-name-transforms
        `((".*" ,auto-save-dir t))))

;; disable sound bell
(setq visible-bell t)

;; enables delete-selection-mode to replace marked text on type
(delete-selection-mode 1)

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
(global-hl-line-mode 1)
;; only highlight the line in the selected window, not every window
(setq hl-line-sticky-flag nil)

;; display line number in the left
(global-display-line-numbers-mode 1)

;; dim the background of inactive (non-selected) windows
;; ====================================================
(defface my/inactive-window-face
  '((t (:background "#14162e")))
  "Face used for the background of non-selected windows.
Slightly grayer than the theme background so the active window
stands out while staying perfectly readable.")

(defvar-local my/inactive-window--cookies nil
  "Face-remap cookies for the filtered dim remaps in this buffer.")

(defun my/dim--ensure-remap (buffer)
  "Install the per-window filtered dim remaps in BUFFER if absent.
The remaps only take effect in windows whose `my/window-dimmed'
parameter is non-nil, so two windows showing the same buffer can
be dimmed independently.  We dim `default' plus the line-number
faces, which the theme otherwise pins to a fixed background."
  (with-current-buffer buffer
    (unless my/inactive-window--cookies
      (setq my/inactive-window--cookies
            (mapcar
             (lambda (face)
               (face-remap-add-relative
                face
                '(:filtered (:window my/window-dimmed t)
                            my/inactive-window-face)))
             '(default line-number line-number-current-line))))))

(defun my/dim-inactive-windows (&rest _)
  "Dim every window except the selected one, per window."
  (let ((selected (selected-window)))
    (walk-windows
     (lambda (win)
       (my/dim--ensure-remap (window-buffer win))
       (set-window-parameter win 'my/window-dimmed (not (eq win selected))))
     nil t)))

(add-hook 'window-configuration-change-hook #'my/dim-inactive-windows)
(add-hook 'window-selection-change-functions #'my/dim-inactive-windows)
(add-hook 'buffer-list-update-hook #'my/dim-inactive-windows)

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

;; map .env files to conf-mode
(add-to-list 'auto-mode-alist '("\\.env\\'" . conf-mode))
(add-to-list 'auto-mode-alist '("\\.env\\..*\\'" . conf-mode))

(provide 'neoarch-customization)
