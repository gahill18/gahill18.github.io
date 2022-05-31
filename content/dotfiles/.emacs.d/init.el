;; --------------- CORE FUNCTIONALITY ---------------

(add-hook 'emacs-lisp-mode-hook 'flycheck-mode)

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
(setq initial-buffer-choice "~/.emacs.d/")      ; Open init on startup

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

(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))

(global-set-key (kbd "<escape>") 'keyboard-escape-quit) ; Make escape quit prompts
(global-set-key (kbd "C-M-<return>") 'eshell)           ; Ctrl-Alt-Enter to open eshell
(global-set-key (kbd "C-M-j") 'counsel-switch-buffer)   ; Ctrl-Alt-j to switch buffer
(global-set-key (kbd "C-M-k") 'kill-this-buffer)        ; Ctrl-Alt-k to kill buffer
(global-set-key (kbd "C-M-;") 'revert-buffer-no-confirm) ; Reload buffer

(global-set-key (kbd "C-M-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "C-M-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "C-M-<down>") 'shrink-window)
(global-set-key (kbd "C-M-<up>") 'enlarge-window)

; Switch windows with arrows
(global-set-key (kbd "C-c j")  'windmove-left)
(global-set-key (kbd "C-c ;") 'windmove-right)
(global-set-key (kbd "C-c k")    'windmove-up)
(global-set-key (kbd "C-c l")  'windmove-down)

(global-set-key (kbd "s-r") 'browse-kill-ring) ; See past cuts/copies

;; -------- FUNCTIONAL PACKAGES --------------

;; Multiple cursor functionality
;; I'm not good at this one yet, its a little freaky
(use-package multiple-cursors)

;; Undo management
(use-package undo-tree)
(global-undo-tree-mode)

;; Killring management
(use-package popup-kill-ring)
(use-package browse-kill-ring
  :bind ("C-M-/" . browse-kill-ring))

;; Emacs startup screen
(use-package dashboard
  :config
  (dashboard-setup-startup-hook))

;; Git packages
(use-package magit)

;; Docker packages
(use-package docker
  :bind ("C-M-d" . docker))

;; Syntax checker and debugger
(use-package flycheck
  :hook prog-mode)
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

;; Display indent guidelines
(use-package indent-guide
  :hook (prog-mode . indent-guide-mode))

;; Better coloring and to make code easier to read
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))
(use-package rainbow-mode
  :hook prog-mode)

;; Better icons for modeline
(use-package all-the-icons)

;; Improved modeline
(use-package doom-modeline
  :ensure t
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

;; Match desktop theme with emacs theme
(use-package theme-magic)

;; ------------ LANGUAGE PACKAGES --------------------

;; IDE for emacs
(use-package lsp-mode
  :hook prog-mode
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (lsp-enable-which-key-integration t))
(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))
(use-package eglot
  :hook (lsp-mode))

;; Haskell Packages
(use-package haskell-mode
  :hook lsp-deferred
  :bind ("C-c C-z" . 'haskell-process-load-file))
(use-package flycheck-haskell
  :after haskell-mode)
(use-package lsp-haskell
  :after haskell-mode)

;; Rust packages
(use-package rust-mode
  :hook lsp-deferred)
(use-package cargo-mode
  :hook rust-mode)
(use-package flycheck-rust
  :hook rust-mode)

;; Better pdf interaction
(use-package pdf-tools
  :mode "\\.pdf\\'")
(pdf-tools-install)

;; ------------ ORG MODE ------------

(add-hook 'org-mode-hook ; Export org
	  (lambda () (local-set-key (kbd "C-M-e") 'org-export-dispatch)))

(add-hook 'org-mode-hook ; Spell check the line
	  (lambda () (local-set-key (kbd "C-M-f") 'flyspell-check-previous-highlighted-word)))

(add-hook 'org-mode-hook 'flyspell-mode) ; Start flyspell mode

;; ------------ HACKS AND MISC IMPROVEMENTS --------------------

(use-package restart-emacs)

;; Tell Custom to piss off and stop changing things
(setq custom-file "~/.emacs.d/custom.el")

;; Source: http://www.emacswiki.org/emacs-en/download/misc-cmds.el
(defun revert-buffer-no-confirm ()
    "Revert buffer without confirmation."
    (interactive)
    (revert-buffer :ignore-auto :noconfirm))
