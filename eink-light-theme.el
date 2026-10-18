;;; eink-light-theme.el --- Light grayscale theme for e-ink displays -*- lexical-binding: t -*-

;; Copyright (C) 2026 Milan Glacier

;; Author: Milan Glacier <dev@milanglacier.com>
;; URL: https://github.com/milanglacier/eink.el
;; Keywords: faces
;; SPDX-License-Identifier: MIT

;; This file is not part of GNU Emacs.

;;; Commentary:

;; The light variant of the eink themes.  See `eink-themes' for details.

;;; Code:

(require 'eink-themes)

(deftheme eink-light
  "Light grayscale theme for e-ink displays."
  :background-mode 'light
  :kind 'color-scheme
  :family 'eink)

(eink-themes-theme 'eink-light 'light)

(provide-theme 'eink-light)

;;; eink-light-theme.el ends here
