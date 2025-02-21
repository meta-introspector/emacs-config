
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'lsp-mode)
(straight-use-package 'magit)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(debug-on-error t)
 '(ellama-code-review-prompt-template "%s")
 '(ellama-provider
   #s(llm-ollama nil nil nil "http" "localhost" 11434 "qwen2.5-coder"
		 "nomic-embed-text"))

 '(org-babel-load-languages '((shell . t)))
 '(org-confirm-babel-evaluate nil)
 '(safe-local-variable-values
   '((whitespace-line-column . 79)
     (eval progn
	   (defun prefix-dir-locals-dir (elt)
	     (concat
	      (locate-dominating-file buffer-file-name
				      ".dir-locals.el")
	      elt))
	   (mapcar
	    (lambda (dir) (add-to-list 'geiser-guile-load-path dir))
	    (mapcar #'prefix-dir-locals-dir '("scripts" "module"))))
     (geiser-active-implementations guile)
     (eval progn
	   (let
	       ((top
		 (locate-dominating-file default-directory
					 ".dir-locals.el"))))
	   (defun guile--manual-look-up (id mod)
	     (message "guile--manual-look-up id=%s => %s mod=%s" id
		      (symbol-name id) mod)
	     (let
		 ((info-lookup-other-window-flag
		   geiser-guile-manual-lookup-other-window-p))
	       (info-lookup-symbol (symbol-name id) 'scheme-mode))
	     (when geiser-guile-manual-lookup-other-window-p
	       (switch-to-buffer-other-window "*info*"))
	     (search-forward (format "%s" id) nil t))
	   (add-hook 'before-save-hook 'delete-trailing-whitespace nil
		     t)
	   (defun guix-switch-profile (&optional profile)
	     "reset Emacs' environment by snarfing PROFILE/etc/profile"
	     (defun matches-in-string (regexp string)
	       "return a list of matches of REGEXP in STRING."
	       (let ((matches))
		 (save-match-data
		   (string-match "^" "")
		   (while (string-match regexp string (match-end 0))
		     (push
		      (or (match-string 1 string)
			  (match-string 0 string))
		      matches)))
		 matches))
	     (interactive "fprofile: ")
	     (let*
		 ((output
		   (shell-command-to-string
		    (concat "GUIX_PROFILE= /bin/sh -x " profile
			    "/etc/profile")))
		  (exports
		   (matches-in-string "^[+] export \\(.*\\)" output)))
	       (mapcar
		(lambda (line)
		  (apply #'setenv (split-string line "=")))
		exports)))
	   (defun shell-args-to-string (&rest args)
	     (shell-command-to-string (mapconcat 'identity args " ")))
	   (defun as (string &optional arch)
	     (let*
		 ((arch (or arch "--64"))
		  (asm (subst-char-in-string 95 32 string))
		  (foo (message "asm:%S" asm))
		  (result
		   (shell-args-to-string "as" arch
					 (concat "<(echo '" asm "')")))
		  (disassembly
		   (shell-args-to-string "objdump" "-d" "a.out"))
		  (foo (message "disassembly: %S" disassembly))
		  (match
		   (string-match "^   0:[\11]\\([^\11]*\\)"
				 disassembly))
		  (code (match-string 1 disassembly))
		  (code (apply 'concat (split-string code " " t))))
	       (insert " ") (insert code)))
	   (defun as-32 (point mark)
	     (interactive "r")
	     (let*
		 ((string (buffer-substring point mark))
		  (code (as string "--32")))
	       (insert " ") (insert code)))
	   (defun as-64 (point mark)
	     (interactive "r")
	     (let*
		 ((string (buffer-substring point mark))
		  (code (as string "--64")))
	       (insert " ") (insert code)))))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'set-goal-column 'disabled nil)
;; ## added by OPAM user-setup for emacs / base ## 56ab50dc8996d2bb95e7856a6eddb17b ## you can edit, but keep this line
;; (require 'opam-user-setup "~/.emacs.d/opam-user-setup.el")
;; ## end of OPAM user-setup addition for emacs / base ## keep this line
(straight-use-package 'fancy-compilation)
(require 'ansi-color)
(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)
(straight-use-package 'flycheck-typescript-tslint)
(straight-use-package 'ellama)
(straight-use-package 'llm )

;; (setopt ellama-coding-provider
;; 	(make-llm-ollama
;;  	 :chat-model "qwen2.5-coder"
;;  	 :embedding-model "nomic-embed-text"
;;  	     :default-chat-non-standard-params '(("num_ctx" . 32768))))


;; terraform and cloudformation modules
(straight-use-package 'yaml)
(straight-use-package 'yaml-mode) 
(straight-use-package 'smart-shift)
(straight-use-package 'terraform-mode)
(straight-use-package 'nix-mode)
(straight-use-package 'docker) 

(setq ring-bell-function 'ignore)


