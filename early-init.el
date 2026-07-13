;;; early-init.el --- Early init: load path + UI tweaks -*- lexical-binding: t; -*-

;; Runs before the initial frame is created.  We add the custom `lisp'
;; directory to `load-path' and load `neoarch-customization' here so the UI
;; tweaks (disabling the menu/tool/scroll bars, frame font, etc.) take effect
;; before the first frame is drawn.  This avoids the brief flash of the default
;; chrome that happens when those tweaks run later from `init.el'.

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'neoarch-customization)

(provide 'early-init)
;;; early-init.el ends here
