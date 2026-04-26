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

;; set theme according to system mode (dark mode vs light mode)
(defun my/apply-theme (appearance)
  "Load theme, taking current system APPEARANCE into consideration."
  (mapc #'disable-theme custom-enabled-themes)
  (pcase appearance
    ('light (load-theme 'tango t))
     ('dark (load-theme 'modus-vivendi t))))
    ;; ('dark (load-theme 'tango t))))
    (add-hook 'ns-system-appearance-change-functions #'my/apply-theme)

(provide 'neoarch-functions)
