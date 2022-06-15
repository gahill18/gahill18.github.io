;; --------------- CORE FUNCTIONALITY ---------------

;; Flash when emacs is angry
(setq visible-bell t)

;; Prettify emacs
(add-to-list 'default-frame-alist
             '(font . "DejaVu Sans Mono 14"))

(column-number-mode)                   ; Add line numbers
(global-display-line-numbers-mode t)
(global-visual-line-mode)

(dolist (mode '(term-mode-hook         ; Turn line numbers off for listed modes
		eshell-mode-hook
		org-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(scroll-bar-mode -1)                   ; Disable visible scroll bar
(tool-bar-mode -1)                     ; Disable tool bar
(tooltip-mode -1)                      ; Disable tool tips
(set-fringe-mode 10)

(menu-bar-mode -1)                     ; Disable menu
(display-time-mode 1)                  ; Display Clock

(setq inhibit-startup-message t)       ; No startup message

(setq auto-save-default nil)           ; Disable autosave
(setq create-lockfiles nil)            ; Disable lockfiles
 

;; Initialize package sources
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ; ("melpa-stable" . "https://stable.melp.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)


;; --------------- KEYBINDS ------------------

;; So we don't have to change every function definition if we want to remap
;; keys later on
(setq movement-key-up "p")
(setq movement-key-down "n")
(setq movement-key-left "b")
(setq movement-key-right "f")

(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))

(global-set-key (kbd "<escape>") 'keyboard-escape-quit) ; Make escape quit prompts
(global-set-key (kbd "C-M-<return>") 'eshell)           ; Ctrl-Alt-Enter to open eshell
(global-set-key (kbd "C-M-j") 'counsel-switch-buffer)   ; Ctrl-Alt-j to switch buffer
(global-set-key (kbd "C-M-k") 'kill-this-buffer)        ; Ctrl-Alt-k to kill buffer
(global-set-key (kbd "C-M-;") 'revert-buffer-no-confirm) ; Reload buffer
(global-set-key (kbd "C-M-o") 'org-agenda) ; Open the agenda
(global-set-key (kbd "s-r") 'browse-kill-ring) ; See past cuts/copies

; Resize windows with arrows
(global-set-key (kbd "C-M-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "C-M-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "C-M-<down>") 'shrink-window)
(global-set-key (kbd "C-M-<up>") 'enlarge-window)

; Switch windows with movement keys
(global-set-key (kbd (concat "C-c " movement-key-left))  'windmove-left)
(global-set-key (kbd (concat "C-c " movement-key-right)) 'windmove-right)
(global-set-key (kbd (concat "C-c " movement-key-up))    'windmove-up)
(global-set-key (kbd (concat "C-c " movement-key-down))  'windmove-down)

;; -------- FUNCTIONAL PACKAGES --------------

;; Multiple cursor functionality
;; I'm not good at this one yet, its a little freaky
(use-package multiple-cursors)

;; Undo management
(use-package undo-tree
   :bind ("C-M-/" . undo-tree-visualize))
(global-undo-tree-mode t)
 
;; Killring management
(use-package browse-kill-ring
   :bind ("C-M-y" . browse-kill-ring))
 
;; Git packages
(use-package magit
  :defer t)

;; Docker packages
(use-package docker
  :bind ("C-M-d" . docker))

;; Syntax checker and debugger
(use-package flycheck
  :hook (prog-mode . flycheck-mode))
;; Flychecks on save
(setq flycheck-check-syntax-automatically '(mode-enabled save))

;; Minibuffer auto complete
(use-package ivy
   :diminish
   :config
   (ivy-mode 1))
 
;; Gives additional info on M-x commands
(use-package ivy-rich
   :init
   (ivy-rich-mode 1))
 
;; Fuzzy search
(use-package counsel
   :bind (("M-x" . counsel-M-x)
 	 ("C-x b" . counsel-ibuffer)
 	 ("C-x C-f" . counsel-find-file)
 	 :map minibuffer-local-map
 	 ("C-r" . 'counsel-minibuffer-history))
   :config
   (setq ivy-initial-inputs-alist nil)) ; Get rid of ^ from searches
 
;; Text completion
(use-package company
   :bind (("C-c c" . company-complete)))
(add-hook 'after-init-hook 'global-company-mode)
 
(use-package helpful
   :custom
   (counsel-describe-function-function #'helpful-callable)
   (counsel-describe-variable-function #'helpful-variable)
   :bind
   ([remap describe-function] . counsel-describe-function)
   ([remap describe-command] . helpful-command)
   ([remap describe-variable] . counsel-describe-variable)
   ([remap describe-key] . helpful-key))
 
;; Tells what options are available under keybindings
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))


;; ------------ AESTHETIC PACKAGES --------------------
 
;; Emacs startup screen
(setq org-agenda-files '("~/org/agenda.org"))
(use-package dashboard
  :config
  (dashboard-setup-startup-hook))
 
;; Display indent guidelines
(use-package indent-guide
  :hook (prog-mode . indent-guide-mode))

;; Better coloring and to make code easier to read
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))
(use-package rainbow-mode
  :hook prog-mode)

;; Better icons for modeline
(use-package all-the-icons
  :defer t)

;; Improved modeline
(use-package doom-modeline
  :init
  (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 20))

;; Adds new, better, themes
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
	doom-themes-enable-italic t
	doom-modeline-enable-word-count t)
  (load-theme 'doom-gruvbox t)
  )
;; 
;; ;; Match desktop theme with emacs theme
;; (use-package theme-magic
;;   :bind ("C-M-t" . theme-magic-from-emacs))
;; 
;; ;; ------------ LANGUAGE PACKAGES --------------------
;; 
;; IDE for emacs
;; (use-package lsp-mode
;;   :hook prog-mode
;;   :commands (lsp lsp-deferred)
;;   :init
;;   (setq lsp-keymap-prefix "C-c l")
;;   :config
;;   (lsp-enable-which-key-integration t))
;; (use-package lsp-ui
;;   :hook (lsp-mode . lsp-ui-mode)
;;   :custom
;;   (lsp-ui-doc-position 'bottom))
;; (use-package eglot
;;   :hook (lsp-mode . eglot))

;; Haskell Packages
(use-package haskell-mode
  :bind ("C-c C-z" . 'haskell-process-load-file))
; (use-package flycheck-haskell
;   :after haskell-mode)
; (use-package lsp-haskell
;   :after haskell-mode)

;; Rust packages
(use-package rust-mode
  :defer t)
(use-package cargo-mode
  :defer t)
;; (use-package flycheck-rust
;;   :hook (rust-mode . flycheck-rust))
;; (use-package racer
;;   :hook (rust-mode . racer-mode))

;; Better pdf interaction
(use-package pdf-tools
  :hook (pdf-view-mode . pdf-tools-enable-minor-modes))

;; ------------ ORG MODE ------------

(add-hook 'org-mode-hook (lambda () (local-set-key (kbd "C-M-f") 'flyspell-check-previous-highlighted-word)))
(add-hook 'org-mode-hook (lambda () (local-set-key (kbd "C-M-e") 'org-export-dispatch)))
(add-hook 'org-mode-hook flyspell-mode)

;; ------------ HACKS AND MISC IMPROVEMENTS --------------------

(use-package selectric-mode
  :bind ("C-s-s" . 'selectric-mode))

(use-package restart-emacs
  :bind ("C-M-r" . 'restart-emacs))

;; Update packages weekly
(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00"))

;; Tell Custom to piss off and stop changing things
(setq custom-file "~/.emacs.d/custom.el")

;; Source: http://www.emacswiki.org/emacs-en/download/misc-cmds.el
(defun revert-buffer-no-confirm ()
    "Revert buffer without confirmation."
    (interactive)
    (revert-buffer :ignore-auto :noconfirm))

; (defun startup-frame ()
;   "Open the buffers I want on startup"
;   (split-window-right)
;   (other-window 1)
;   (split-window-below)
;   (other-window -1))

; (startup-frame)                                 ; Startup frame management
