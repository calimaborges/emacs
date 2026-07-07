;;; neoarch-functions.el --- my personal config functions

(defvar my/projects-root "~/projects"
  "The root directory containing all profile folders.")

(defvar my/current-profile nil
  "The currently active profile.")

(defvar my/current-project nil
  "The currently active project folder name.")

(defun my/get-profiles ()
  "Return a list of profiles directories inside `my/projects-root`."
  (when (file-directory-p my/projects-root)
    (directory-files my/projects-root nil "^[^.]")))

(defun my/get-projects-for-profile (profile)
  "Return a list of projects for the given PROFILE."
  (let ((profile-path (expand-file-name profile my/projects-root)))
    (when (file-directory-p profile-path)
      (directory-files profile-path nil "^[^.]"))))

(defun journal-edit ()
    "Open today's journal entry based on my/projects-root. If the file doesn't exist, create it and insert a org header."
  (interactive)
  (let* ((current-date (format-time-string "%Y-%m-%d"))
	  (journal-dir (expand-file-name "personal/journal" my/projects-root))
	  (file-path (expand-file-name (format "%s.org" current-date) journal-dir)))
    (unless (file-exists-p file-path)
      (with-temp-file file-path
	(insert (format "* %s\n\n" current-date))))

    (find-file file-path)
    (message "Opened journal entry for %s" current-date)))

(defun init-edit ()
  "Open the init file."
  (interactive)
  (find-file user-init-file))

(defun functions-edit ()
  "Open functions folder."
  (interactive)
  (find-file (expand-file-name "lisp/" user-emacs-directory)))

(defun my/persp-vterm (&optional new-terminal)
  "Switch to a vterm buffer for the current perspective.
If none exists, create one.
With a prefix (`C-u`), force the creation of a new vterm buffer."
  (interactive "P")
  (require 'vterm)
  (require 'perspective)
  (let* ((p-name (persp-name (persp-curr)))
         ;; create a base name for the terminal based on the perspective
         (base-name (format "*vterm-%s*" p-name))
         ;; get all buffers currently associated with this perspective
         (persp-bufs (persp-buffers (persp-curr)))

         ;; filter the list to find only our perspective-specific vterms
         (existing-vterms (seq-filter (lambda (buf) (string-prefix-p base-name (buffer-name buf)))
                                       persp-bufs)))
    (if (or new-terminal (null existing-vterms))
        ;; create new vterm with an auto-increment name
        ;; (e.g., *vterm-work*, *vterm-work*<2>)
        (vterm (generate-new-buffer-name base-name))
      ;; otherwise, swith to the first existing vterm we found
      (switch-to-buffer (car existing-vterms)))))

(setq neoarch-context-list '(personal tst runeform))
(defun neoarch-new-project ()
  "Create a new project."
  (interactive)
  (let* ((context (completing-read "Context: " neoarch-context-list))
         (project (read-string "Project: "))
         (project-dir (file-name-concat my/projects-root context project)))
    (make-directory (file-name-as-directory project-dir))
    (make-empty-file (file-name-concat project-dir ".projectile"))))

(global-set-key (kbd "C-c p n") 'neoarch-new-project)
(global-set-key (kbd "C-c t") 'my/persp-vterm)

(provide 'neoarch-functions)
