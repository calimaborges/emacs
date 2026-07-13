;;; gptel-config.el --- gptel/LLM configuration -*- lexical-binding: t; -*-

(use-package gptel
  :ensure t
  :config
  (defvar my-anthropic-backend
    (gptel-make-anthropic "Anthropic"
      :key 'gptel-api-key-from-auth-source
      :stream t
      :models '(claude-haiku-4-5-20251001
                claude-sonnet-4-6
                claude-opus-4-6
                claude-opus-4-7)))
  ;; set it as your default backend
  (setq gptel-backend my-anthropic-backend)
  ;; set default model
  (setq gptel-model 'claude-haiku-4-5-20251001)
  ;; set tools
  (setq gptel-tools
        (list (gptel-make-tool
               :name "git-log"
               :description "Query git commit history with flexible options"
               :args (list
                      (list :name "query" :description "Search term" :type "string")
                      (list :name "limit" :description "Max commits to return" :type "integer"))
               :category "git"
               :function (lambda (query limit)
                           (shell-command-to-string
                            (format "git log --all --oneline -n %d --grep '%s'"
                                    (or limit 10) query))))))
  ;; set directives
  (setf (alist-get 'commit-writter gptel-directives)
        "- Analyze the diffs attached
- Look at the last 10 git commits and use it as exemplars of good commit messages
- Return only the git message")

  (setf (alist-get 'grammar-checker gptel-directives)
        "- Check the phrasing. Make sure it is correct, polite and gentle.
- Output the phrasing with some corrections
- Check if there is any recommendation for improvement on clarity and naturality
- Write the recommendations separated by bullet points with full examples")
  :bind (("C-c RET" . gptel-send)))

(provide 'gptel-config)
