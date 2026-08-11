;;; neoarch-keybinding.el --- global keybindings -*- lexical-binding: t; -*-
(require 'neoarch-functions)

(dolist (group neoarch/keybinding-groups)
  (pcase-dolist (`(,key ,_description ,command) (cdr group))
    (when command
      (global-set-key (kbd key) command))))

(dotimes (i 9)
  (let ((number (1+ i)))
    (global-set-key (kbd (format "s-%d" number))
                    (lambda ()
                      (interactive)
                      (persp-switch-by-number number)))))

(global-set-key (kbd "C-<tab>") #'persp-next)
(global-set-key (kbd "C-S-<tab>") #'persp-prev)

(global-set-key (kbd "C-x p") 'projectile-command-map)

(with-eval-after-load 'eglot
  (define-key eglot-mode-map (kbd "C-c r") #'eglot-rename)
  (define-key eglot-mode-map (kbd "C-c a") #'eglot-code-actions)
  (define-key eglot-mode-map (kbd "C-c f") #'eglot-format-buffer)
  (define-key eglot-mode-map (kbd "M-n") #'flymake-goto-next-error)
  (define-key eglot-mode-map (kbd "M-p") #'flymake-goto-prev-error))

(neoarch/vterm-setup-passthrough "C-c C-k")

(provide 'neoarch-keybinding)
