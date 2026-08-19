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

;; auto close pairs
;; ================
(electric-pair-mode 1)

(defvar neoarch-html-void-elements
  '("area" "base" "br" "col" "embed" "hr" "img" "input"
    "link" "meta" "param" "source" "track" "wbr")
  "HTML void elements that must not get an auto-inserted close tag.")

(defun neoarch-html-electric-pair-inhibit (char)
  "Inhibit pairing `<` so HTML tags are typed as `<div>`, not `<>`."
  (or (eq char ?<)
      (electric-pair-default-inhibit char)))

(defun neoarch-html-start-tag-at-gt ()
  "Return the `start_tag` node closed by the `>' before point, or nil."
  (when-let* ((node (treesit-node-at (1- (point)) 'html))
              (tag (if (equal (treesit-node-type node) "start_tag")
                       node
                     (treesit-node-parent node)))
              ((equal (treesit-node-type tag) "start_tag"))
              ((eq (treesit-node-end tag) (point))))
    tag))

(defun neoarch-html-start-tag-needs-closer-p (start-tag)
  "Return non-nil when START-TAG has no matching `end_tag` yet."
  (let ((element (treesit-node-parent start-tag)))
    (not (and (equal (treesit-node-type element) "element")
              (treesit-filter-child
               element
               (lambda (child)
                 (equal (treesit-node-type child) "end_tag"))
               t)))))

(defun neoarch-html-insert-gt ()
  "Insert `>' and a matching close tag after a non-void start tag."
  (interactive)
  (if (eq (char-after) ?>)
      (forward-char)
    (insert ">")
    (when-let* ((tag (neoarch-html-start-tag-at-gt))
                ((neoarch-html-start-tag-needs-closer-p tag))
                (name-node (car (treesit-filter-child
                                 tag
                                 (lambda (child)
                                   (equal (treesit-node-type child) "tag_name"))
                                 t)))
                (name (treesit-node-text name-node t)))
      (unless (member (downcase name) neoarch-html-void-elements)
        (save-excursion
          (insert "</" name ">"))))))
(put 'neoarch-html-insert-gt 'delete-selection t)

(defun neoarch-html-setup-auto-close ()
  "Enable tag pairing and `>' auto-close in HTML buffers."
  (setq-local electric-pair-inhibit-predicate
              #'neoarch-html-electric-pair-inhibit)
  (setq-local sgml-quick-keys 'close)
  (sgml-electric-tag-pair-mode 1))

(add-hook 'html-ts-mode-hook #'neoarch-html-setup-auto-close)
(with-eval-after-load 'html-ts-mode
  (define-key html-ts-mode-map (kbd ">") #'neoarch-html-insert-gt))

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

;; hide CSS color previews on the current line
;; ============================================
;; `css-mode' paints color values (e.g. #f4f4f5) with the color as the
;; background and a contrasting black/white foreground, via text
;; properties.  The hl-line overlay draws on top of text-property
;; backgrounds, leaving the contrast foreground behind -- so light
;; colors render black-on-black on the highlighted line.  Instead, strip
;; the preview from the line point is on and restore it when point
;; leaves the line.

(defvar-local my/css-color--line-beg nil
  "Marker at the start of the line whose color previews are hidden.")
(defvar-local my/css-color--line-end nil
  "Marker at the end of the line whose color previews are hidden.")

(defun my/css-color--strip (beg end)
  "Remove css color-preview faces between BEG and END."
  (with-silent-modifications
    (save-excursion
      (goto-char beg)
      (let ((case-fold-search t))
        (while (re-search-forward css--colors-regexp end t)
          (let ((face (get-text-property (match-beginning 0) 'face)))
            (when (and (consp face) (plist-member face :background))
              (remove-text-properties (match-beginning 0) (match-end 0)
                                      '(face nil)))))))))

(defun my/css-color--fontify-region (orig beg end &optional loudly)
  "Run ORIG on BEG..END, then hide color previews on the tracked line."
  (let ((ret (funcall orig beg end loudly)))
    (when (and css-fontify-colors
               my/css-color--line-beg
               (marker-position my/css-color--line-beg))
      (let ((rbeg (if (eq (car-safe ret) 'jit-lock-bounds) (cadr ret) beg))
            (rend (if (eq (car-safe ret) 'jit-lock-bounds) (cddr ret) end))
            (lbeg (marker-position my/css-color--line-beg))
            (lend (marker-position my/css-color--line-end)))
        (when (and (< lbeg rend) (> lend rbeg))
          (my/css-color--strip (max rbeg lbeg) (min rend lend)))))
    ret))

(defun my/css-color--track-line ()
  "Refontify the old and new line whenever point moves to another line."
  (let ((beg (line-beginning-position))
        (end (line-end-position)))
    (unless (and my/css-color--line-beg
                 (eql beg (marker-position my/css-color--line-beg)))
      (let ((old-beg (and my/css-color--line-beg
                          (marker-position my/css-color--line-beg)))
            (old-end (and my/css-color--line-end
                          (marker-position my/css-color--line-end))))
        (if my/css-color--line-beg
            (progn (set-marker my/css-color--line-beg beg)
                   (set-marker my/css-color--line-end end))
          ;; End marker advances when typing at end of line, so previews
          ;; typed on the current line are hidden too.
          (setq my/css-color--line-beg (copy-marker beg))
          (setq my/css-color--line-end (copy-marker end t)))
        (when (and old-beg old-end (< old-beg old-end))
          (font-lock-flush old-beg old-end))
        (when (< beg end)
          (font-lock-flush beg end))))))

(with-eval-after-load 'css-mode
  (advice-add 'css--fontify-region :around #'my/css-color--fontify-region)
  (add-hook 'css-base-mode-hook
            (lambda ()
              (add-hook 'post-command-hook #'my/css-color--track-line nil t))))

;; display line number in the left
(global-display-line-numbers-mode 1)

;; dim the background of inactive (non-selected) windows
;; ====================================================
(defface my/inactive-window-face
  '((t (:background "#030412")))
  "Face used for the background of non-selected windows.
Darker than the theme background so inactive windows recede and
the selected one reads as the focused canvas.")

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
             '(default fringe line-number line-number-current-line))))))

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

;; JS/TS/HTML/JSON/CSS: treesit indent + Eglot format (:tabSize ← tab-width) share this.
(defvar neoarch-js-ts-indent 2
  "Indent width for JS/TS/HTML/JSON/CSS editing and Eglot format-on-save.")
(defun neoarch-js-ts-indent-setup ()
  (setq-local tab-width neoarch-js-ts-indent
              js-ts-mode-indent-offset neoarch-js-ts-indent
              typescript-ts-mode-indent-offset neoarch-js-ts-indent
              html-ts-mode-indent-offset neoarch-js-ts-indent
              json-ts-mode-indent-offset neoarch-js-ts-indent
              css-indent-offset neoarch-js-ts-indent))
(dolist (hook '(js-ts-mode-hook typescript-ts-mode-hook tsx-ts-mode-hook
                                html-ts-mode-hook json-ts-mode-hook
                                css-base-mode-hook))
  (add-hook hook #'neoarch-js-ts-indent-setup))

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

(defun neoarch-exec-path-prepend (dir)
  "Prepend DIR to `exec-path' and PATH when it exists."
  (setq dir (directory-file-name (expand-file-name dir)))
  (when (file-directory-p dir)
    (setq exec-path (cons dir (delete dir exec-path)))
    (let* ((path (or (getenv "PATH") ""))
           (parts (delete dir (split-string path path-separator t))))
      (setenv "PATH" (mapconcat #'identity (cons dir parts) path-separator)))))

(defun neoarch-opam-executable ()
  "Return the opam executable, searching buffer-local then global `exec-path'."
  (or (executable-find "opam")
      (let ((exec-path (default-value 'exec-path)))
        (executable-find "opam"))))

(defun neoarch-opam-apply-env ()
  "Apply the current opam switch to `exec-path' and the process environment."
  (when-let* ((opam (neoarch-opam-executable))
              (env (ignore-errors
                     (with-temp-buffer
                       (when (eq 0 (call-process opam nil t nil
                                                 "env" "--sexp" "--readonly"))
                         (goto-char (point-min))
                         (read (current-buffer)))))))
    (dolist (binding env)
      (unless (equal (car binding) "PATH")
        (setenv (car binding) (cadr binding))))
    (when-let ((prefix (cadr (assoc "OPAM_SWITCH_PREFIX" env))))
      (neoarch-exec-path-prepend (expand-file-name "bin" prefix)))))

(defun neoarch-mise-merge-opam-env ()
  "Re-apply the opam switch after `mise-mode' replaces buffer-local PATH."
  (when mise-mode
    (neoarch-opam-apply-env)))

(dolist (dir '("/usr/local/bin"
               "/opt/homebrew/bin"
               "~/.local/bin"
               "~/.local/share/mise/shims"))
  (neoarch-exec-path-prepend dir))
(neoarch-opam-apply-env)
(with-eval-after-load 'mise
  (add-hook 'mise-mode-hook #'neoarch-mise-merge-opam-env))

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

;; list directories separated from files in dired
(require 'ls-lisp)
(setq ls-lisp-use-insert-directory-program nil)
(setq ls-lisp-dirs-first t)

(setq epa-file-encrypt-to '("36ACD11BFB9CDCF4DD2AF5882B842B2570C82E16"))
(setq epa-file-select-keys 'silent)
(setq epg-pinentry-mode 'loopback)

(provide 'neoarch-customization)
