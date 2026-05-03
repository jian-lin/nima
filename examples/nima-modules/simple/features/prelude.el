;; load dependencies on which all features can depend
(require 'cl-lib)
(require 'xdg)

;; define things that all features can use
(defconst my-emacs-data-directory (expand-file-name "emacs/" (xdg-data-home))
  "A directory to store Emacs data such as backup files and autosave files.")
(make-directory my-emacs-data-directory t)
