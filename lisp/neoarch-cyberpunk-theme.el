;;; neoarch-cyberpunk-theme.el --- Cyberpunk + Hollywood UI theme -*- lexical-binding: t; -*-

;; A homegrown dark theme leaning into neon-noir: deep midnight backgrounds,
;; hot magenta keywords, electric cyan identifiers, matrix-green strings,
;; HUD-style chrome.  No external packages required — everything is plain
;; face definitions on top of the built-in faces shipped with Emacs.

(deftheme neoarch-cyberpunk
  "Cyberpunk + Hollywood-UI dark theme. Neon on midnight.")

(let* ((bg            "#0a0c1f")  ; deep midnight, the canvas
       (bg-alt        "#11142b")  ; mode line, hl-line, cards
       (bg-dim        "#181c38")  ; selection, code blocks
       (bg-glow       "#23264f")  ; raised surfaces, isearch
       (fg            "#e6e6fa")  ; lavender white default text
       (fg-alt        "#b8b8d4")  ; muted body text
       (fg-dim        "#6e6e9a")  ; comments, line numbers
       (fg-faint      "#3a3d6a")  ; fringe, dim borders
       (magenta       "#ff2a6d")  ; hot pink: keywords, cursor, errors
       (magenta-bright "#ff5e9c") ; brighter magenta for emphasis
       (cyan          "#05d9e8")  ; electric cyan: functions, links
       (cyan-bright   "#5ef0fb")  ; brighter cyan for accents
       (purple        "#b14aed")  ; neon purple: types
       (blue          "#4cc9f0")  ; sky neon: variables, params
       (green         "#39ff14")  ; matrix green: strings, success
       (yellow        "#ffd60a")  ; amber: builtins, warnings
       (orange        "#ff8b3d")  ; warning, constants
       (red           "#ff003c")  ; critical error
       (white         "#ffffff")
       (black         "#000000"))

  (custom-theme-set-faces
   'neoarch-cyberpunk

   ;; --- core ----------------------------------------------------------------
   `(default              ((t (:background ,bg :foreground ,fg))))
   `(cursor               ((t (:background ,magenta))))
   `(region               ((t (:background ,bg-glow :extend t))))
   `(secondary-selection  ((t (:background ,bg-dim))))
   `(highlight            ((t (:background ,bg-glow :foreground ,cyan-bright))))
   `(hl-line              ((t (:background ,black :extend t))))
   `(fringe               ((t (:background ,bg :foreground ,fg-faint))))
   `(vertical-border      ((t (:foreground ,fg-faint))))
   `(window-divider       ((t (:foreground ,fg-faint))))
   `(window-divider-first-pixel ((t (:foreground ,fg-faint))))
   `(window-divider-last-pixel  ((t (:foreground ,fg-faint))))
   `(link                 ((t (:foreground ,cyan :underline t))))
   `(link-visited         ((t (:foreground ,purple :underline t))))
   `(success              ((t (:foreground ,green :weight bold))))
   `(warning              ((t (:foreground ,yellow :weight bold))))
   `(error                ((t (:foreground ,red :weight bold))))
   `(shadow               ((t (:foreground ,fg-dim))))
   `(escape-glyph         ((t (:foreground ,magenta-bright))))
   `(trailing-whitespace  ((t (:background ,red))))

   ;; --- HUD: mode line & echo area ------------------------------------------
   `(mode-line            ((t (:background ,bg-alt :foreground ,cyan-bright
                               :box (:line-width 4 :color ,bg-alt)))))
   `(mode-line-inactive   ((t (:background ,bg :foreground ,fg-dim
                               :box (:line-width 4 :color ,bg)))))
   `(mode-line-highlight  ((t (:foreground ,magenta-bright :weight bold))))
   `(mode-line-buffer-id  ((t (:foreground ,magenta :weight bold))))
   `(mode-line-emphasis   ((t (:foreground ,cyan :weight bold))))
   `(header-line          ((t (:background ,bg-alt :foreground ,cyan
                               :box (:line-width 4 :color ,bg-alt)))))
   `(minibuffer-prompt    ((t (:foreground ,magenta :weight bold))))

   ;; --- line numbers --------------------------------------------------------
   `(line-number              ((t (:background ,black :foreground ,fg-faint))))
   `(line-number-current-line ((t (:background ,black :foreground ,cyan :weight bold))))

   ;; --- syntax (font-lock) --------------------------------------------------
   `(font-lock-comment-face        ((t (:foreground ,fg-dim :slant italic))))
   `(font-lock-comment-delimiter-face ((t (:foreground ,fg-faint :slant italic))))
   `(font-lock-doc-face            ((t (:foreground ,fg-alt :slant italic))))
   `(font-lock-string-face         ((t (:foreground ,green))))
   `(font-lock-keyword-face        ((t (:foreground ,magenta :weight bold))))
   `(font-lock-builtin-face        ((t (:foreground ,yellow))))
   `(font-lock-function-name-face  ((t (:foreground ,cyan :weight bold))))
   `(font-lock-variable-name-face  ((t (:foreground ,blue))))
   `(font-lock-type-face           ((t (:foreground ,purple :weight bold))))
   `(font-lock-constant-face       ((t (:foreground ,orange))))
   `(font-lock-preprocessor-face   ((t (:foreground ,magenta-bright))))
   `(font-lock-warning-face        ((t (:foreground ,red :weight bold))))
   `(font-lock-negation-char-face  ((t (:foreground ,red))))
   `(font-lock-regexp-grouping-construct ((t (:foreground ,magenta-bright :weight bold))))
   `(font-lock-regexp-grouping-backslash ((t (:foreground ,yellow))))

   ;; --- parens & matching ---------------------------------------------------
   `(show-paren-match     ((t (:background ,magenta :foreground ,bg :weight bold))))
   `(show-paren-mismatch  ((t (:background ,red :foreground ,white :weight bold))))

   ;; --- search --------------------------------------------------------------
   `(isearch              ((t (:background ,magenta :foreground ,bg :weight bold))))
   `(isearch-fail         ((t (:background ,red :foreground ,white))))
   `(lazy-highlight       ((t (:background ,bg-glow :foreground ,cyan-bright))))
   `(match                ((t (:background ,bg-glow :foreground ,green :weight bold))))

   ;; --- completion (fido / icomplete / completions) -------------------------
   `(completions-common-part      ((t (:foreground ,cyan :weight bold))))
   `(completions-first-difference ((t (:foreground ,magenta :weight bold))))
   `(completions-annotations      ((t (:foreground ,fg-dim :slant italic))))
   `(icomplete-selected-match     ((t (:background ,bg-glow :foreground ,magenta-bright :weight bold))))

   ;; --- whitespace mode -----------------------------------------------------
   `(whitespace-trailing   ((t (:background ,red :foreground ,white))))
   `(whitespace-tab        ((t (:background ,bg-alt :foreground ,fg-faint))))
   `(whitespace-space      ((t (:foreground ,fg-faint))))
   `(whitespace-newline    ((t (:foreground ,fg-faint))))
   `(whitespace-line       ((t (:background ,bg-alt :foreground ,yellow))))

   ;; --- which-key -----------------------------------------------------------
   `(which-key-key-face                  ((t (:foreground ,magenta :weight bold))))
   `(which-key-separator-face            ((t (:foreground ,fg-dim))))
   `(which-key-command-description-face  ((t (:foreground ,fg))))
   `(which-key-group-description-face    ((t (:foreground ,cyan :weight bold))))
   `(which-key-special-key-face          ((t (:foreground ,green :weight bold))))

   ;; --- magit (subset, common ones) -----------------------------------------
   `(magit-section-heading        ((t (:foreground ,magenta :weight bold))))
   `(magit-section-highlight      ((t (:background ,bg-alt :extend t))))
   `(magit-branch-local           ((t (:foreground ,cyan :weight bold))))
   `(magit-branch-remote          ((t (:foreground ,purple :weight bold))))
   `(magit-branch-current         ((t (:foreground ,green :weight bold :box (:line-width 1 :color ,green)))))
   `(magit-tag                    ((t (:foreground ,yellow :weight bold))))
   `(magit-hash                   ((t (:foreground ,fg-dim))))
   `(magit-log-author             ((t (:foreground ,blue))))
   `(magit-log-date               ((t (:foreground ,fg-dim))))
   `(magit-diff-added             ((t (:background "#0a2018" :foreground ,green))))
   `(magit-diff-added-highlight   ((t (:background "#0d2e21" :foreground ,green :extend t))))
   `(magit-diff-removed           ((t (:background "#220914" :foreground ,magenta-bright))))
   `(magit-diff-removed-highlight ((t (:background "#33121e" :foreground ,magenta-bright :extend t))))
   `(magit-diff-context           ((t (:foreground ,fg-alt))))
   `(magit-diff-context-highlight ((t (:background ,bg-alt :foreground ,fg :extend t))))
   `(magit-diff-hunk-heading           ((t (:background ,bg-dim :foreground ,cyan))))
   `(magit-diff-hunk-heading-highlight ((t (:background ,bg-glow :foreground ,cyan-bright :weight bold))))

   ;; --- org -----------------------------------------------------------------
   `(org-level-1          ((t (:foreground ,magenta :weight bold :height 1.15))))
   `(org-level-2          ((t (:foreground ,cyan :weight bold :height 1.08))))
   `(org-level-3          ((t (:foreground ,purple :weight bold))))
   `(org-level-4          ((t (:foreground ,blue :weight bold))))
   `(org-level-5          ((t (:foreground ,yellow))))
   `(org-level-6          ((t (:foreground ,green))))
   `(org-document-title   ((t (:foreground ,magenta-bright :weight bold :height 1.3))))
   `(org-document-info    ((t (:foreground ,cyan))))
   `(org-todo             ((t (:foreground ,red :weight bold :box t))))
   `(org-done             ((t (:foreground ,green :weight bold :box t))))
   `(org-headline-done    ((t (:foreground ,fg-dim :strike-through t))))
   `(org-block            ((t (:background ,bg-alt :extend t))))
   `(org-block-begin-line ((t (:background ,bg-alt :foreground ,fg-dim :extend t))))
   `(org-block-end-line   ((t (:background ,bg-alt :foreground ,fg-dim :extend t))))
   `(org-code             ((t (:foreground ,cyan-bright :background ,bg-alt))))
   `(org-verbatim         ((t (:foreground ,green :background ,bg-alt))))
   `(org-link             ((t (:foreground ,cyan :underline t))))
   `(org-date             ((t (:foreground ,purple :underline t))))
   `(org-tag              ((t (:foreground ,yellow))))

   ;; --- diff / ediff (built-in) --------------------------------------------
   `(diff-added           ((t (:background "#0a2018" :foreground ,green))))
   `(diff-removed         ((t (:background "#220914" :foreground ,magenta-bright))))
   `(diff-changed         ((t (:foreground ,yellow))))
   `(diff-header          ((t (:background ,bg-alt :foreground ,cyan))))
   `(diff-file-header     ((t (:background ,bg-alt :foreground ,magenta :weight bold))))
   `(diff-hunk-header     ((t (:background ,bg-dim :foreground ,purple))))

   ;; --- compilation ---------------------------------------------------------
   `(compilation-error    ((t (:foreground ,red :weight bold))))
   `(compilation-warning  ((t (:foreground ,yellow :weight bold))))
   `(compilation-info     ((t (:foreground ,cyan))))

   ;; --- vterm (best-effort; most colors come from term faces) ---------------
   `(term-color-black     ((t (:background ,bg :foreground ,fg-dim))))
   `(term-color-red       ((t (:background ,red :foreground ,red))))
   `(term-color-green     ((t (:background ,green :foreground ,green))))
   `(term-color-yellow    ((t (:background ,yellow :foreground ,yellow))))
   `(term-color-blue      ((t (:background ,blue :foreground ,blue))))
   `(term-color-magenta   ((t (:background ,magenta :foreground ,magenta))))
   `(term-color-cyan      ((t (:background ,cyan :foreground ,cyan))))
   `(term-color-white     ((t (:background ,fg :foreground ,fg))))))

(provide-theme 'neoarch-cyberpunk)
;;; neoarch-cyberpunk-theme.el ends here
