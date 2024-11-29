;;; run-tests.el --- Script to run elfeed-sync tests

;; Setup package archives and initialize
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Ensure required packages are installed
(package-refresh-contents)
(dolist (pkg '(elfeed async))
  (unless (package-installed-p pkg)
    (package-install pkg)))

;; Add your Elisp files to the load path
(dolist (path '("./" "../"))
  (add-to-list 'load-path (expand-file-name path)))

;; Load and run the tests
(load "tests/elfeed-sync-test")
(ert-run-tests-batch-and-exit)
