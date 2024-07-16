(keyboard-translate ?\C-h ?\C-?)
(keyboard-translate ?\C-? ?\C-h)

(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

(if (getenv "http_proxy")
    (setq url-proxy-services
	  `(("http" . ,(replace-regexp-in-string "^.*://" "" (getenv "http_proxy")))
	    ("https" . ,(replace-regexp-in-string "^.*://" "" (getenv "https_proxy"))))))

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/") t)
;; (add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(package-initialize)

(setq inferior-lisp-program "sbcl")

(defun require-package (package &optional min-version no-refresh)
  "Install given PACKAGE, optionally requiring MIN-VERSION.
If NO-REFRESH is non-nil, the available package lists will not be
re-downloaded in order to locate PACKAGE."
  (if (package-installed-p package min-version)
    t
    (if (or (assoc package package-archive-contents) no-refresh)
      (if (boundp 'package-selected-packages)
        ;; Record this as a package the user installed explicitly
        (package-install package nil)
        (package-install package))
      (progn
        (package-refresh-contents)
        (require-package package min-version t)))))

(defun maybe-require-package (package &optional min-version no-refresh)
  "Try to install PACKAGE, and return non-nil if successful.
In the event of failure, return nil and print a warning message.
Optionally require MIN-VERSION.  If NO-REFRESH is non-nil, the
available package lists will not be re-downloaded in order to
locate PACKAGE."
  (condition-case err
    (require-package package min-version no-refresh)
    (error
      (message "Couldn't install optional package `%s': %S" package err)
      nil)))

;; (require 'auto-complete)
;; (require 'auto-complete-config)
;; (global-auto-complete-mode t)
;; (setq-default ac-sources '(ac-source-filename ac-source-words-in-same-mode-buffers))
;; (add-hook 'emacs-lisp-mode-hook (lambda () (add-to-list 'ac-sources 'ac-source-symbols t)))

;; (add-hook 'slime-repl-mode-hook 'set-up-slime-ac)
;; (eval-after-load "auto-complete"
;;   '(add-to-list 'ac-modes 'slime-repl-mode))

(when (and (maybe-require-package 'slime)
	   (maybe-require-package 'slime-company))
  
  (add-hook 'after-init-hook 'global-company-mode)

  (slime-setup '(slime-fancy slime-company))

  (put 'case-match 'common-lisp-indent-function '(as case))
  (put 'dbind 'common-lisp-indent-function '(as multiple-value-bind))
  (put 'let+ 'common-lisp-indent-function '(as let)))

;(require 'lsp-mode)
;(lsp-register-client
;   (make-lsp-client
;    :new-connection (lsp-stdio-connection
;                     '("opam" "exec" "--" "ocamlmerlin-lsp"))
;    :major-modes '(caml-mode tuareg-mode)
;    :server-id 'ocamlmerlin-lsp))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(magit rainbow-delimiters lsp-mode slime-company auto-install ac-slime)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;; ## added by OPAM user-setup for emacs / base ## 56ab50dc8996d2bb95e7856a6eddb17b ## you can edit, but keep this line
(require 'opam-user-setup "~/.emacs.d/opam-user-setup.el")
;; ## end of OPAM user-setup addition for emacs / base ## keep this line

(load-theme 'tango-dark t)

;; rainbow-delimiters を使うための設定
(when (maybe-require-package 'rainbow-delimiters)
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

  ;; 括弧の色を強調する設定
  (when (and 
	 (maybe-require-package 'cl-lib)
	 (maybe-require-package 'color))
    (defun rainbow-delimiters-using-stronger-colors ()
      (interactive)
      (require 'cl-lib)
      (require 'color)
      (cl-loop
       for index from 1 to rainbow-delimiters-max-face-count
       do
       (let ((face (intern (format "rainbow-delimiters-depth-%d-face" index))))
	 (cl-callf color-saturate-name (face-foreground face) 30))))
    (add-hook 'emacs-startup-hook 'rainbow-delimiters-using-stronger-colors)))

;; magit
(global-set-key (kbd "C-x g") 'magit-status)

;; geiser
(when (maybe-require-package 'geiser)
  (setq geiser-active-implementations '(mit))
  (defun geiser-save ()
    (interactive)
    (geiser-repl-write-input-ring)))
