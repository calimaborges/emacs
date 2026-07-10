(global-set-key (kbd "C-c p n") 'neoarch-new-project)
(global-set-key (kbd "C-c t") 'my/persp-vterm)
(global-set-key (kbd "C-x g") 'magit-status)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(global-set-key (kbd "C-x C-b") 'persp-list-buffers)
(define-key projectile-command-map (kbd "p") 'projectile-persp-switch-project)

(provide 'neoarch-keybinding)
