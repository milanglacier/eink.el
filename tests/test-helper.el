;;; test-helper.el --- Test bootstrap for eink-themes -*- lexical-binding: t -*-

;; Copyright (C) 2026 Milan Glacier

;; Author: Milan Glacier <dev@milanglacier.com>
;; Assisted-by: Pi:claude-opus-5-5
;; SPDX-License-Identifier: MIT

;; This file is not part of GNU Emacs.

;;; Commentary:

;; Shared setup for batch runs under `emacs -Q'.  Packages are
;; installed with `package.el' into an isolated `package-user-dir', so
;; the runs do not depend on any user configuration.  The directory is
;; EINK_THEMES_TEST_EMACS_DIR, or a temporary directory that is deleted
;; when Emacs exits.

;;; Code:

(require 'package)

(defconst eink-themes-test-popular-packages
  '(magit evil company corfu vertico consult marginalia orderless embark
    doom-modeline nerd-icons helpful markdown-mode rainbow-delimiters
    yasnippet hl-todo diff-hl)
  "Third-party packages that `make test-full' checks.")

(defvar eink-themes-test--temp-emacs-dir nil
  "Temporary Emacs directory created for the current run.")

(defun eink-themes-test--emacs-dir ()
  "Return the isolated Emacs directory for the current run."
  (or (getenv "EINK_THEMES_TEST_EMACS_DIR")
      (setq eink-themes-test--temp-emacs-dir
            (or eink-themes-test--temp-emacs-dir
                (make-temp-file "eink-themes-test-emacs-" t)))))

(defun eink-themes-test--delete-temp-dir ()
  "Delete the temporary Emacs directory created for the current run."
  (when (and eink-themes-test--temp-emacs-dir
             (file-directory-p eink-themes-test--temp-emacs-dir))
    (delete-directory eink-themes-test--temp-emacs-dir t)))

(defun eink-themes-test-ensure-packages (packages)
  "Install each package in PACKAGES that is not installed yet."
  (when-let* ((missing (seq-remove #'package-installed-p packages)))
    (package-refresh-contents)
    (dolist (package missing)
      (package-install package))))

(setq user-emacs-directory
      (file-name-as-directory (eink-themes-test--emacs-dir))
      load-prefer-newer t
      package-user-dir (expand-file-name "elpa" user-emacs-directory)
      package-check-signature nil
      package-quickstart nil
      package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("melpa" . "https://melpa.org/packages/"))
      package-archive-priorities '(("gnu" . 30)
                                   ("nongnu" . 20)
                                   ("melpa" . 10)))
(package-initialize)
(add-hook 'kill-emacs-hook #'eink-themes-test--delete-temp-dir)

(provide 'test-helper)

;;; test-helper.el ends here
