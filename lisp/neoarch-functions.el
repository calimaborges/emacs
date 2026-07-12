;;; neoarch-functions.el --- my personal config functions
(defvar neoarch/projects-root "~/projects"
  "The root directory containing all profile folders.")

(defun neoarch/get-profiles ()
  "Return a list of profiles directories inside `neoarch/projects-root`."
  (when (file-directory-p neoarch/projects-root)
    (directory-files neoarch/projects-root nil "^[^.]")))

(defun neoarch/get-projects-for-profile (profile)
  "Return a list of projects for the given PROFILE."
  (let ((profile-path (expand-file-name profile neoarch/projects-root)))
    (when (file-directory-p profile-path)
      (directory-files profile-path nil "^[^.]"))))

(defun neoarch/project-terminal (&optional new-terminal)
  "Switch to a vterm buffer for the current perspective.
If none exists, create one.
With a prefix (`C-u`), force the creation of a new vterm buffer."
  (interactive "P")
  (require 'vterm)
  (require 'perspective)
  (let* ((p-name (persp-name (persp-curr)))
         (base-name (format "*vterm-%s*" p-name))
         (persp-bufs (persp-buffers (persp-curr)))
         (existing-vterms (seq-filter (lambda (buf) (string-prefix-p base-name (buffer-name buf)))
                                       persp-bufs)))
    (if (or new-terminal (null existing-vterms))
        (vterm (generate-new-buffer-name base-name))
      (pop-to-buffer-same-window (car existing-vterms)))))

(defun neoarch/project-create ()
  "Create a new project."
  (interactive)
  (let* ((profile (completing-read "Profile: " (neoarch/get-profiles)))
         (project (read-string "Project: "))
         (project-dir (file-name-concat neoarch/projects-root profile project)))
    (make-directory project-dir t)
    (make-empty-file (file-name-concat project-dir ".projectile"))
    (when (featurep 'projectile) (projectile-add-known-project project-dir))))

(defun neoarch/project-open ()
  "Open a project using projectile."
  (interactive)
  (let ((projectile-switch-project-action #'projectile-dired))
    (call-interactively #'projectile-persp-switch-project)))

(defun neoarch/project-close ()
  "Kill the current perspective and close the project buffers."
  (interactive)
  (message "Is this the function it is calling?")
  (when (and (boundp 'persp-mode) persp-mode)
    (persp-kill (persp-curr-name)))
  (projectile-kill-buffers))

(defun neoarch/project-switch ()
  "Switch to an already active project/perspective."
  (interactive)
  (call-interactively #'persp-switch))

(defun neoarch/project-find-file ()
  "Find a file within the current projectile project."
  (interactive)
  (call-interactively #'projectile-find-file))

(defun neoarch/project-grep ()
  "Grep through the current project."
  (interactive)
  (call-interactively #'projectile-ripgrep))

(defvar-local neoarch/vterm-saved-exceptions nil
  "Stores original vterm exceptions when pure passthrough is active.")

(defcustom neoarch/vterm-passthrough-key "C-c C-k"
  "The key sequence used to toggle pure passthrough in vterm."
  :type 'string
  :group 'neoarch)

(defcustom neoarch/vterm-passthrough-prefix "C-c"
  "The prefix key that Emacs must intercept during vterm passthrough.
This should match the first key in `neoarch/vterm-passthrough-key`."
  :type 'string
  :group 'neoarch)

(defvar-local neoarch/vterm-saved-exceptions nil
  "Stores original vterm exceptions when pure passthrough is active.")
(defvar neoarch/vterm-passthrough-prefix "C-c"
  "Prefix to ignore during passthrough. Set via `neoarch/setup-vterm-passhtrough`.")
(defun neoarch/vterm-setup-passthrough (full-key)
  "Configure and bind vterm passthrough toggle.
FULL-KEY is the exact binding (e.g., \"C-c C-k\")."
  (let ((prefix-key (car (split-string full-key " "))))
    (setq neoarch/vterm-passthrough-prefix prefix-key)
    (with-eval-after-load 'vterm
      (define-key vterm-mode-map (kbd full-key) #'neoarch/vterm-toggle-passthrough))))
(defun neoarch/vterm-toggle-passthrough ()
  "Toggle pure passthrough mode.
When active, standard Emacs keys are sent directly to the terminal.
The prefix defined in `neoarch/vterm-passthrough-prefix` is preserved."
  (interactive)
  (if neoarch/vterm-saved-exceptions
      (progn
        (dolist (key neoarch/vterm-saved-exceptions)
          (unless (equal key neoarch/vterm-passthrough-prefix)
            (local-unset-key (kbd key))))
        (setq neoarch/vterm-saved-exceptions nil)
        (message "Exited pure passthrough. Standard Emacs keys restored."))
    (setq neoarch/vterm-saved-exceptions vterm-keymap-exceptions)
    (dolist (key neoarch/vterm-saved-exceptions)
      (unless (equal key neoarch/vterm-passthrough-prefix)
        (local-set-key (kbd key) #'vterm--self-insert)))
    (message "Pure passthrough active!")))

;; Automatically bind whatever the user set the variable to
(with-eval-after-load 'vterm
  (define-key vterm-mode-map (kbd neoarch/vterm-passthrough-key) #'neoarch/vterm-toggle-passthrough))

(defun neoarch/vc-status ()
  "Show version control status in repository."
  (interactive)
  (call-interactively #'magit-status))

;; function commands
(defun journal-edit ()
  "Open today's journal entry based on neoarch/projects-root. If the file doesn't exist, create it and insert a org header."
  (interactive)
  (require 'persp-projectile)
  (require 'magit)
  (let* ((current-date (format-time-string "%Y-%m-%d"))
         (journal-dir (expand-file-name "personal/journal" neoarch/projects-root))
         (journal-file (expand-file-name (format "%s.org" current-date) journal-dir))
         (journal-file-rx (rx string-start (= 4 digit) "-" (= 2 digit) "-" (= 2 digit) ".org" string-end))
         (journal-files (directory-files journal-dir t journal-file-rx))
         (journal-files-except-today (seq-remove (lambda (filename)
                                                   (string= filename journal-file))
                                                 journal-files))
         (last-file (car (sort journal-files-except-today #'string-greaterp))))
    (message "Last journal %s %s" journal-file last-file)
    (let ((projectile-switch-project-action #'ignore)) (projectile-persp-switch-project journal-dir))
    (let ((default-directory journal-dir)) (magit-call-git "pull"))
    (delete-other-windows)
    (unless (file-exists-p journal-file)
      (with-temp-file journal-file
        (insert (format "* %s\n\n" current-date))))
    (find-file last-file)
    (select-window (split-window-right))
    (find-file journal-file)
    (message "Opened journal entry for %s" current-date)))

(defun init-edit ()
  "Open the init file."
  (interactive)
  (let ((projectile-switch-project-action #'projectile-dired))
    (projectile-persp-switch-project user-emacs-directory)))

(provide 'neoarch-functions)
