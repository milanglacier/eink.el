;;; eink-dark-theme.el --- Dark grayscale theme for e-ink displays -*- lexical-binding: t -*-

;; Copyright (C) 2026 Milan Glacier

;; Author: Milan Glacier <dev@milanglacier.com>
;; URL: https://github.com/milanglacier/eink.el
;; Keywords: faces
;; SPDX-License-Identifier: MIT

;; This file is not part of GNU Emacs.

;;; Commentary:

;; The dark variant of the eink themes.  See `eink-themes' for details.

;;; Code:

(require 'eink-themes)

(deftheme eink-dark
  "Dark grayscale theme for e-ink displays."
  :background-mode 'dark
  :kind 'color-scheme
  :family 'eink)

(eink-themes-theme 'eink-dark 'dark)

(provide-theme 'eink-dark)

;;; eink-dark-theme.el ends here
