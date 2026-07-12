(global-set-key (kbd "C-x x t") 'neoarch/project-terminal)
(global-set-key (kbd "C-x x n") 'neoarch/project-create)
(global-set-key (kbd "C-x x o") 'neoarch/project-open)
(global-set-key (kbd "C-x x c") 'neoarch/project-close)
(global-set-key (kbd "C-x x s") 'neoarch/project-switch)
(global-set-key (kbd "C-x x f") 'neoarch/project-find-file)
(global-set-key (kbd "C-x x g") 'neoarch/project-grep)

(global-set-key (kbd "C-x g") 'neoarch/vc-status)
(neoarch/vterm-setup-passthrough "C-c C-k")

(provide 'neoarch-keybinding)
