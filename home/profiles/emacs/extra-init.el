(require 'sanityinc-tomorrow-eighties-theme)
(load-theme 'sanityinc-tomorrow-eighties t)

;; (require 'poet-theme)
;; (load-theme 'poet t)

(let ((file "~/org/config.el"))
  (when (file-exists-p file)
    (load-file file)))

(when (and custom-file (file-exists-p custom-file))
  (load custom-file))

(run-with-timer 2 nil
                (defun akirak/org-dog-load-on-startup ()
                  ;; I don't want to hide the init time in the echo area.
                  (let ((inhibit-message t))
                    (require 'org-dog nil t)
                    (when (fboundp 'org-dog-reload-files)
                      (org-dog-reload-files t)))))
