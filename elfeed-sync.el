;;; elfeed-sync.el --- Synchronize index of elfeed  -*- lexical-binding:t -*-

;; Copyright (C) 2023 Masaki Waga

;; Maintainer: Masaki Waga
;; Keywords: RSS, elfeed

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

;; Define functions to pull or push the index file of elfeed to synchronize
;; the database of elfeed <https://github.com/skeeto/elfeed> among multiple
;; computers.

;;; Code:

(require 'elfeed)
(require 'tramp)

(defcustom elfeed-sync-remote-index-path
  "/ssh:foo@example.com:.elfeed/index"
  "The TRAMP path to push or pull the Elfeed index file.")

(defun elfeed-sync--local-index-path ()
  "Return the path of the Elfeed index file."
  (expand-file-name "index" elfeed-db-directory))

(defun elfeed-sync-push ()
  "Push the local Elfeed index file to a remote location.
This function saves the current state of the Elfeed database and
then uses Emacs TRAMP to copy the index file to the specified remote path."
  (interactive)
  (message "Starting Elfeed index push...")
  (elfeed-db-save)
  (let ((local-index (elfeed-sync--local-index-path))
        (remote-index elfeed-sync-remote-index-path))
    (condition-case err
        (progn
          (copy-file local-index remote-index 1)
          (message "Elfeed index pushed successfully."))
      (error (message "Error during Elfeed index push: %s" err)
             (signal (car err) (cdr err))))))

(defun elfeed-sync-pull ()
  "Pull the Elfeed index file from a remote location.
This function uses Emacs TRAMP to copy the index file from the specified
remote path to the local Elfeed database directory, and then
loads the new database state."
  (interactive)
  (message "Starting Elfeed index pull...")
  (let ((local-index (elfeed-sync--local-index-path))
        (remote-index elfeed-sync-remote-index-path))
    (condition-case err
        (progn
          (copy-file remote-index local-index 1)
          (elfeed-db-load)
          (message "Elfeed index pulled successfully."))
      (error (message "Error during Elfeed index pull: %s" err)
             (signal (car err) (cdr err))))))

(provide 'elfeed-sync)
;;; elfeed-sync.el ends here
