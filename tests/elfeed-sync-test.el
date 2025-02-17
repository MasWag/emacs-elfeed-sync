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
(require 'async)

;; Test if `elfeed-db-directory` exists and is correctly set
(ert-deftest elfeed-sync-test-elfeed-db-directory-exists ()
  (should (boundp 'elfeed-db-directory))
  (should (stringp elfeed-db-directory)))

;; Test push/pull with an accessible local file
(ert-deftest elfeed-sync-test-push-pull-local ()
  (let ((elfeed-sync-local-index-path (elfeed-sync--local-index-path))
        (elfeed-sync-remote-index-path (make-temp-file "elfeed-test-index"))
        (backup-local-index-path (make-temp-file "elfeed-backup-index"))
        (dummy-data ";;; Elfeed Database Index (version 4)\n\n;; Dummy index for backwards compatablity:\n(:version \"0.0.3\" :feeds #s(hash-table size 65 test equal rehash-size 1.5 rehash-threshold 0.800000011920929 data ()) :entries #s(hash-table size 65 test equal rehash-size 1.5 rehash-threshold 0.800000011920929 data ()) :index [cl-struct-avl-tree- [nil nil nil 0] elfeed-db-compare])"))

    ;; Ensure the local index file exists
    (unless (file-exists-p elfeed-sync-local-index-path)
      (write-region "This is a dummy index file" nil elfeed-sync-local-index-path))

    ;; Backup the original local index file
    (copy-file elfeed-sync-local-index-path backup-local-index-path t)

    ;; Ensure the remote file is empty
    (write-region "" nil elfeed-sync-remote-index-path)

    ;; Perform the push operation and wait until the async operation completes, ensuring sufficient time
    (async-wait (elfeed-sync-push))

    ;; Check that the content of elfeed-sync-remote-index-path and elfeed-sync-local-index-path are identical
    (should (string= (with-temp-buffer
                       (insert-file-contents elfeed-sync-local-index-path)
                       (buffer-string))
                     (with-temp-buffer
                       (insert-file-contents elfeed-sync-remote-index-path)
                       (buffer-string))))

    ;; Make a dummy remote index file
    (write-region dummy-data nil elfeed-sync-remote-index-path)

    ;; Perform the pull operation and wait until the async operation completes, ensuring sufficient time
    (async-wait (elfeed-sync-pull))

    ;; Assert the content of the pulled file
    (should (string= dummy-data (with-temp-buffer
                                  (insert-file-contents elfeed-sync-local-index-path)
                                  (buffer-string))))

    ;; Recover the original local index
    (copy-file backup-local-index-path elfeed-sync-local-index-path t)))


;; Test error handling with an inaccessible remote server
(ert-deftest elfeed-sync-test-error-handling ()
  (let ((elfeed-sync-remote-index-path "/ssh:foo@example.invalid:/path/to/index"))
    ;; Perform push operation and wait for any async errors
    (condition-case err
        (progn
          (async-wait (elfeed-sync-push))
          (should-error (signal (car err) (cdr err))))
      (error (message "Expected error occurred during Elfeed push: %s" err)))

    ;; Perform pull operation and wait for any async errors
    (condition-case err
        (progn
          (async-wait (elfeed-sync-pull))
          (should-error (signal (car err) (cdr err))))
      (error (message "Expected error occurred during Elfeed pull: %s" err)))))

(provide 'elfeed-sync-test)
;;; elfeed-sync-test.el ends here
