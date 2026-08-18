(keyboard-translate ?\C-h ?\C-?)
(keyboard-translate ?\C-? ?\C-h)

(if (getenv "http_proxy")
    (setq url-proxy-services
	  `(("http" . ,(replace-regexp-in-string "^.*://" "" (getenv "http_proxy")))
	    ("https" . ,(replace-regexp-in-string "^.*://" "" (getenv "https_proxy"))))))

(require 'package)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa" . "https://melpa.org/packages/")))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; 補完系
(use-package vertico
  :init
  (vertico-mode)
  :config
  (savehist-mode 1)
  (recentf-mode 1))

(use-package orderless)
(use-package consult)
(use-package marginalia :init (marginalia-mode))

(use-package corfu
  :init
  (global-corfu-mode)
  (setq completion-styles '(orderless basic)))

(eglot-ensure)

;; face
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(load-theme 'tango-dark t)

;; rainbow-delimiters を使うための設定
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode)
  :init
  ;; 括弧の色を強調する設定
  (defun rainbow-delimiters-using-stronger-colors ()
    (interactive)
    (use-package cl-lib)
    (use-package color)
    (cl-loop
     for index from 1 to rainbow-delimiters-max-face-count
     do
     (let ((face (intern (format "rainbow-delimiters-depth-%d-face" index))))
       (cl-callf color-saturate-name (face-foreground face) 30))))
  (add-hook 'emacs-startup-hook 'rainbow-delimiters-using-stronger-colors))

;; magit
(use-package magit :bind ("C-x g" . magit-status))

;; sly
(use-package sly :init (setq inferior-lisp-program "sbcl"))

;; geiser
(use-package geiser
  :config
  (setq geiser-active-implementations '(gauche mit racket))
  (defun geiser-save ()
    (interactive)
    (geiser-repl-write-input-ring)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(lisp-mode-hook '(sly-editing-mode))
 '(package-selected-packages
   '(consult corfu geiser magit marginalia orderless rainbow-delimiters
	     sly vertico)))
