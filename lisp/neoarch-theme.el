;;; neoarch-theme.el --- personal theme configuration -*- lexical-binding: t; -*-

;; Loads our homegrown `neoarch-cyberpunk' theme (defined in
;; neoarch-cyberpunk-theme.el) when the system is in dark mode and the
;; built-in `tango' when it's in light mode.  On macOS the active theme
;; switches live when the user toggles dark/light mode.

;; Make our hand-rolled themes discoverable to `load-theme'.
(let ((theme-dir (file-name-directory (or load-file-name buffer-file-name))))
  (add-to-list 'custom-theme-load-path theme-dir))

(defvar my/dark-theme 'neoarch-cyberpunk
  "Theme to load when the system is in dark mode.")

(defvar my/light-theme 'tango
  "Theme to load when the system is in light mode.")

(defun my/apply-theme (appearance)
  "Load the theme that matches APPEARANCE (`light' or `dark').
Disables any currently enabled themes first so faces don't leak between them."
  (mapc #'disable-theme custom-enabled-themes)
  (pcase appearance
    ('light (load-theme my/light-theme t))
    ('dark  (load-theme my/dark-theme t))
    (_      (load-theme my/dark-theme t))))

(defun my/system-appearance ()
  "Return the current system appearance symbol, or nil if unknown."
  (cond
   ((boundp 'ns-system-appearance) ns-system-appearance)
   (t nil)))

(my/apply-theme (or (my/system-appearance) 'dark))

(when (boundp 'ns-system-appearance-change-functions)
  (add-hook 'ns-system-appearance-change-functions #'my/apply-theme))

;; --- Hollywood-UI nudges that are independent of the theme palette ---------

;; Slim, padded mode line: show buffer, modes, and position in a HUD strip.
(setq-default mode-line-format
              '("%e"
                mode-line-front-space
                mode-line-mule-info
                mode-line-modified
                "  "
                mode-line-buffer-identification
                "   "
                (vc-mode vc-mode)
                "   "
                mode-line-position
                "   "
                mode-line-modes
                mode-line-misc-info
                mode-line-end-spaces))

(provide 'neoarch-theme)
;;; neoarch-theme.el ends here
