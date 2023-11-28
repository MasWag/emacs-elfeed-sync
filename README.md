emacs-elfeed-sync
=================

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](./LICENSE)
[![Unit Test](https://github.com/MasWag/emacs-elfeed-sync/actions/workflows/unit_test.yml/badge.svg?branch=master)](https://github.com/MasWag/emacs-elfeed-sync/actions/workflows/unit_test.yml)

`emacs-elfeed-sync` is an Emacs package for synchronizing the Elfeed RSS feed reader's database index file across multiple devices. [TRAMP](https://www.gnu.org/software/tramp/) is used to push and pull the index file.

Prerequisites
-------------

- GNU Emacs
- [elfeed](https://github.com/skeeto/elfeed)

Installation and configuration
------------------------------

### Installation

1. Clone or download this repository or the `elfeed-sync.el` file.
2. Place `elfeed-sync.el` in your Emacs load path.

### Configuration with `use-package`

An example configuration of `emacs-elfeed-sync` with `use-package` is as follows:

```emacs-lisp
(use-package elfeed-sync
  :config
  ;; The remote index path for synchronization. Any protocol supported by TRAMP can be used.
  (setq elfeed-sync-remote-index-path "/ssh:user@example.com:.elfeed/index")
  :bind (:map elfeed-search-mode-map
              ("P" . elfeed-sync-push)
              ("F" . elfeed-sync-pull)))
```

This configuration:
- Sets the remote index path for synchronization.
- Binds the `P` key to `elfeed-sync-push` and the `F` key to `elfeed-sync-pull` in the Elfeed search mode.


### Manual configuration

The following shows an (almost) equivalent configuration without `use-package`.

```emacs-lisp
(require 'elfeed-sync)
;; Set the remote index path for synchronization. Replace with your details.
(setq elfeed-sync-remote-index-path "/ssh:user@example.com:.elfeed/index")

;; Optional: Set keybindings for elfeed-search-mode.
(with-eval-after-load 'elfeed-search
  (define-key elfeed-search-mode-map (kbd "P") 'elfeed-sync-push)
  (define-key elfeed-search-mode-map (kbd "F") 'elfeed-sync-pull))
```

Usage
-----

After configuring, you can use the following commands within Elfeed:

- `M-x elfeed-sync-push`: Pushes the local Elfeed index to the remote location.
- `M-x elfeed-sync-pull`: Pulls the remote Elfeed index to the local machine.

License
-------

Licensed under the GNU General Public License v3.0. See [LICENSE](LICENSE) for more details.
