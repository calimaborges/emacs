;;; neoarch-functions.el --- my personal config functions -*- lexical-binding: t; -*-
(defvar neoarch/projects-root "~/projects"
  "The root directory containing all profile folders.")

;; Declared special so our `let' overrides bind dynamically (projectile reads
;; this variable at runtime). Needed under `lexical-binding' when projectile
;; may not be loaded at byte-compile time.
(defvar projectile-switch-project-action)

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
  "Toggle the vterm buffer for the current perspective.
Create one if none exists.  When already inside the perspective's
vterm, jump back to the previously selected buffer.
With a prefix (`C-u`), force the creation of a new vterm buffer."
  (interactive "P")
  (require 'vterm)
  (require 'perspective)
  (let* ((p-name (persp-name (persp-curr)))
         (base-name (format "*vterm-%s*" p-name))
         (persp-bufs (persp-buffers (persp-curr)))
         (existing-vterms (seq-filter (lambda (buf) (string-prefix-p base-name (buffer-name buf)))
                                       persp-bufs)))
    (cond
     (new-terminal (vterm (generate-new-buffer-name base-name)))
     ((string-prefix-p base-name (buffer-name))
      (switch-to-buffer (other-buffer)))
     ((null existing-vterms) (vterm (generate-new-buffer-name base-name)))
     (t (pop-to-buffer-same-window (car existing-vterms))))))

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
  (call-interactively #'persp-kill))

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

(defun neoarch/switch-to-perspective-buffer (prompt predicate empty-message)
  "Switch to a current-perspective buffer matching PREDICATE."
  (require 'perspective)
  (let ((buffers (seq-filter (lambda (buffer)
                               (and (buffer-live-p buffer)
                                    (funcall predicate buffer)))
                             (persp-current-buffers))))
    (unless buffers
      (user-error "%s" empty-message))
    (switch-to-buffer
     (completing-read prompt (mapcar #'buffer-name buffers) nil t))))

(defun neoarch/switch-to-file-buffer ()
  "Switch to a file-visiting buffer within the current perspective."
  (interactive)
  (neoarch/switch-to-perspective-buffer
   "File buffer: "
   #'buffer-file-name
   "No file buffers in the current perspective"))

(defun neoarch/switch-to-terminal-buffer ()
  "Switch to a vterm buffer within the current perspective."
  (interactive)
  (neoarch/switch-to-perspective-buffer
   "Terminal: "
   (lambda (buffer)
     (eq (buffer-local-value 'major-mode buffer) 'vterm-mode))
   "No terminal buffers in the current perspective"))

(defun neoarch/switch-to-other-buffer ()
  "Switch to a non-file, non-terminal buffer within the current perspective."
  (interactive)
  (neoarch/switch-to-perspective-buffer
   "Other buffer: "
   (lambda (buffer)
     (and (not (buffer-file-name buffer))
          (not (eq (buffer-local-value 'major-mode buffer) 'vterm-mode))
          (not (string-prefix-p " " (buffer-name buffer)))))
   "No other buffers in the current perspective"))

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
         (journal-file (expand-file-name (format "%s.org.gpg" current-date) journal-dir)))
    (let ((projectile-switch-project-action #'ignore)) (projectile-persp-switch-project journal-dir))
    (let ((default-directory journal-dir)) (magit-call-git "pull"))
    (delete-other-windows)
    (let* ((journal-file-rx (rx string-start (= 4 digit) "-" (= 2 digit) "-" (= 2 digit) ".org" (? ".gpg") string-end))
           (journal-files (directory-files journal-dir t journal-file-rx))
           (journal-files-except-today (seq-remove (lambda (filename)
                                                     (string= filename journal-file))
                                                   journal-files))
           (last-file (car (sort journal-files-except-today #'string-greaterp))))
      (message "Last journal %s %s" journal-file last-file)
      (unless (file-exists-p journal-file)
        (with-temp-file journal-file
          (insert (format "* %s\n\n" current-date))))
      (find-file last-file))
    (select-window (split-window-right))
    (find-file journal-file)
    (message "Opened journal entry for %s" current-date)))

(defun init-edit ()
  "Open the init file."
  (interactive)
  (let ((projectile-switch-project-action #'projectile-dired))
    (projectile-persp-switch-project user-emacs-directory)))

(defun init-reload ()
  "Re-evaluate all Neoarch lisp modules in place.
For a fully clean slate use `restart-emacs' instead."
  (interactive)
  (dolist (module '("neoarch-customization"
                    "neoarch-functions"
                    "neoarch-theme"
                    "neoarch-package"
                    "neoarch-keybinding"))
    (load (expand-file-name (concat "lisp/" module) user-emacs-directory)))
  (message "Neoarch init reloaded"))

(defvar neoarch/keybinding-groups
  '(("Projects & Perspectives"
     ("s-j" "Switch perspective" neoarch/project-switch)
     ("s-1 .. s-9" "Switch perspective by number")
     ("C-<tab> / C-S-<tab>" "Next / previous perspective")
     ("s-o" "Open project in a new perspective" neoarch/project-open)
     ("s-n" "Create project" neoarch/project-create)
     ("s-q" "Close project perspective" neoarch/project-close)
     ("s-w" "Close current buffer" kill-current-buffer)
     ("C-x p" "Projectile command prefix"))
    ("Windows"
     ("s-<arrows>" "Focus window in direction"))
    ("Files & Search"
     ("s-p" "Find file in project" neoarch/project-find-file)
     ("s-f" "Ripgrep in project" neoarch/project-grep))
    ("Buffers"
     ("s-b" "Switch to file buffer in perspective" neoarch/switch-to-file-buffer)
     ("s-B" "Switch to other buffer in perspective" neoarch/switch-to-other-buffer))
    ("Terminal"
     ("s-t" "Toggle project terminal (C-u: new one)" neoarch/project-terminal)
     ("C-`" "Toggle project terminal" neoarch/project-terminal)
     ("s-`" "Switch to terminal in perspective" neoarch/switch-to-terminal-buffer)
     ("C-c C-k" "Toggle vterm passthrough (in vterm)"))
    ("Version Control"
     ("C-x g" "Magit status" neoarch/vc-status))
    ("Eglot"
     ("M-. / M-, / M-?" "Definition / back / references")
     ("C-c r" "Rename symbol")
     ("C-c a" "Code actions")
     ("C-c f" "Format buffer")
     ("M-n / M-p" "Next / previous diagnostic"))
    ("Help"
     ("C-x x" "Show this cheat sheet" neoarch/describe-keybindings)))
  "Keybinding scheme grouped by topic.
Each entry is (KEY DESCRIPTION [COMMAND]).  Entries with a COMMAND are
bound globally by `neoarch-keybinding'; the rest are display-only.")

(defun neoarch/describe-keybindings ()
  "Display a cheat sheet of the keybinding scheme."
  (interactive)
  (with-help-window "*Neoarch Keybindings*"
    (with-current-buffer standard-output
      (dolist (group neoarch/keybinding-groups)
        (insert (propertize (car group) 'face 'bold) "\n")
        (pcase-dolist (`(,key ,description ,command) (cdr group))
          (insert (if command
                      (format "  %-22s %-42s%s" key description
                              (propertize (symbol-name command) 'face 'shadow))
                    (format "  %-22s %s" key description))
                  "\n"))
        (insert "\n")))))

(provide 'neoarch-functions)
