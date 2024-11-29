;;; run-tests.el --- Script to run elfeed-sync tests

;; Setup package archives and initialize
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Refresh package contents and install elfeed if not already installed
(unless (package-installed-p 'elfeed)
  (package-refresh-contents)
  (package-install 'elfeed))

;; Add your Elisp files to the load path
(add-to-list 'load-path "./")
(add-to-list 'load-path "../")

;; Load and run the tests
(load "tests/elfeed-sync-test")
(ert-run-tests-batch-and-exit)
