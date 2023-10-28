;;; akirak-org-ql.el --- org-ql extensions -*- lexical-binding: t -*-

(require 'org-ql)

(require 'org-dog)
(require 'org-reverse-datetree)

(org-ql-defpred dogm ()
  "Filter entries that are meaningful per org-dog scheme."
  :body (if-let (obj (org-dog-buffer-object))
            (org-dog-meaningful-in-file-p obj)
          t))

(org-ql-defpred (proj my-project) ()
  "Filter entries that are related to the current project."
  :normalizers ((`(,predicate-names)
                 (when-let (pr (project-current))
                   (let ((root (abbreviate-file-name (project-root pr)))
                         (origin (ignore-errors
                                   ;; TODO: Break the host and path
                                   (car (magit-config-get-from-cached-list
                                         "remote.origin.url")))))
                     `(or (regexp ,(regexp-quote root))
                          (property "GIT_ORIGIN" ,origin :inherit t))))))
  :body t)

(org-ql-defpred datetree ()
  "Return non-nil if the entry is a direct child of a date entry."
  :body
  (org-reverse-datetree-date-child-p))

(org-ql-defpred archived ()
  "Return non-nil if the entry is archived."
  :body
  (org-in-archived-heading-p))

(org-ql-defpred recur ()
  "Return non-nil if the entry has an `org-recur' annotation"
  :body
  (org-recur--get-next-date
   (org-get-heading t t t t)))

(org-ql-defpred edna-blocked ()
  "Return non-nil if the entry is blocked by org-edna."
  :body
  (let ((org-blocker-hook '(org-edna-blocker-function)))
    (org-entry-blocked-p)))

(defcustom akirak-org-ql-default-query-prefix "!archived: "
  ""
  :type 'string)

;;;###autoload
(defun akirak-org-ql-find-default (files)
  ;; Deprecated. Use `org-pivot-search-from-files' instead.
  (require 'org-ql-find)
  (let ((org-ql-find-display-buffer-action '(pop-to-buffer)))
    (org-ql-find files :query-prefix akirak-org-ql-default-query-prefix)))

(defvar akirak-org-ql-link-query nil)

;;;###autoload
(defun akirak-org-ql-open-link (files)
  "Open a link at a heading from FILES."
  (require 'org-ql-completing-read)
  (unless akirak-org-ql-link-query
    (setq akirak-org-ql-link-query
          (format "heading-regexp:%s "
                  ;; org-link-any-re contains a space, which makes it unsuitable
                  ;; for use in non-sexp org-ql queries.
                  (rx-to-string `(or (and "http" (?  "s") ":")
                                     (regexp ,org-link-bracket-re))))))
  (if-let (marker (org-ql-completing-read files
                    :query-prefix (concat akirak-org-ql-default-query-prefix
                                          akirak-org-ql-link-query)))
      (org-with-point-at marker
        (org-back-to-heading)
        (org-match-line org-complex-heading-regexp)
        (goto-char (match-beginning 4))
        (org-open-at-point))
    (duckduckgo (car minibuffer-history))))

(provide 'akirak-org-ql)
;;; akirak-org-ql.el ends here
