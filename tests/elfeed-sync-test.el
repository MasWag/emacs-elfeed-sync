;;; elfeed-sync-test.el --- Tests for elfeed-sync package -*- lexical-binding: t; -*-

;; Copyright (C) 2023 Masaki Waga

;; This file is NOT a part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Unit test cases for elfeed-sync.

;;; Code:

(require 'ert)
(require 'elfeed-sync)

;; Test if `elfeed-db-directory` exists and is correctly set
(ert-deftest elfeed-sync-test-elfeed-db-directory-exists ()
  (should (boundp 'elfeed-db-directory))
  (should (stringp elfeed-db-directory)))

;; Test push/pull with an accessible local file
(ert-deftest elfeed-sync-test-push-pull-local ()
  (let ((elfeed-sync-remote-index-path (make-temp-file "elfeed-test-index")))
    ;; Ensure the file exists and is empty
    (write-region "" nil elfeed-sync-remote-index-path)

    ;; Perform the push operation
    (elfeed-sync-push)
    ;; Check if the file was modified (not empty)
    (should (not (string= "" (with-temp-buffer
                               (insert-file-contents elfeed-sync-remote-index-path)
                               (buffer-string)))))

    ;; Perform the pull operation
    (elfeed-sync-pull)
    ;; Additional checks can be added here if needed
    ))

;; Test error handling with an inaccessible remote server
(ert-deftest elfeed-sync-test-error-handling ()
  (let ((elfeed-sync-remote-index-path "/ssh:foo@example.invalid:/path/to/index"))
    (should-error (elfeed-sync-push))
    (should-error (elfeed-sync-pull))))

(ert-deftest elfeed-sync-test-error-message-push ()
  (let ((elfeed-sync-remote-index-path "/ssh:foo@example.invalid:/path/to/index")
        (original-messages (current-message)))
    (condition-case nil
        (elfeed-sync-push)
      (error nil))
    ;; Check the *Messages* buffer for the expected error message
    (should (string-match-p "Error during Elfeed index push:.*" (current-message)))
    ;; Restore the original message
    (message "%s" original-messages)))

(ert-deftest elfeed-sync-test-error-message-pull ()
  (let ((elfeed-sync-remote-index-path "/ssh:foo@example.invalid:/path/to/index")
        (original-messages (current-message)))
    (condition-case nil
        (elfeed-sync-pull)
      (error nil))
    ;; Check the *Messages* buffer for the expected error message
    (should (string-match-p "Error during Elfeed index pull:.*" (current-message)))
    ;; Restore the original message
    (message "%s" original-messages)))

(provide 'elfeed-sync-test)
;;; elfeed-sync-test.el ends here
