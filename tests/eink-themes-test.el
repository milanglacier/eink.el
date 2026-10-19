;;; eink-themes-test.el --- Tests for eink-themes -*- lexical-binding: t -*-

;; Copyright (C) 2026 Milan Glacier

;; Author: Milan Glacier <dev@milanglacier.com>
;; Assisted-by: Pi:claude-opus-5-5
;; SPDX-License-Identifier: MIT

;; This file is not part of GNU Emacs.

;;; Commentary:

;; Run the tests with `make test'.  `make test-full' also installs the
;; packages in `eink-themes-test-popular-packages' and checks them.

;;; Code:

(require 'ert)
(require 'cl-lib)
(require 'subr-x)
(require 'term/tty-colors)
(require 'eink-themes)

(defconst eink-themes-test--root
  (file-name-directory
   (directory-file-name
    (file-name-directory (or load-file-name buffer-file-name))))
  "Directory that holds the source files of the package.")

(defconst eink-themes-test--themes '(eink-light eink-dark)
  "The themes under test.")

(defconst eink-themes-test--builtin-libraries
  '(ansi-color apropos bookmark calendar cal-iso diary-lib add-log
    log-edit compile comint completion-preview cus-edit custom wid-edit
    diff-mode dired dired-x ediff eglot eldoc epa ert eshell em-ls em-prompt
    eww shr flymake flyspell hexl hi-lock hideshow ibuffer icomplete info
    isearch kmacro log-view man woman message gnus gnus-art gnus-sum
    gnus-group gnus-srvr gnus-cite mm-decode mm-uu outline package proced
    pulse re-builder ruler-mode shortdoc smerge-mode speedbar tab-bar
    tab-line table term textsec transient vc vc-dir vc-git vc-hooks
    which-func which-key whitespace xref elisp-mode org org-agenda org-habit
    org-clock org-table org-faces ox-beamer rcirc erc erc-button erc-match
    erc-goodies erc-stamp erc-fill erc-capab markdown-ts-mode dictionary
    cua-base ebrowse edebug gdb-mi generic-x gomoku image-dired ido
    make-mode mpuz newst-reader newst-plainview newst-treeview nxml-mode
    prolog rst sh-script spam strokes testcover todo-mode vhdl-mode
    verilog-mode vera-mode viper window-tool-bar doc-view emoji
    emacs-authors-mode eieio-custom erts-mode pcvs semantic semantic/decorate
    semantic/util-modes srecode/fields tooltip simple help-mode display-line-numbers)
  "Built-in libraries that define faces with colors.")

(defun eink-themes-test--call-with-clean-themes (function)
  "Call FUNCTION with no theme enabled, then restore the enabled themes."
  (let ((saved custom-enabled-themes))
    (unwind-protect
        (progn
          (mapc #'disable-theme custom-enabled-themes)
          (funcall function))
      (mapc #'disable-theme custom-enabled-themes)
      (mapc #'enable-theme (reverse saved)))))

(defmacro eink-themes-test--with-clean-themes (&rest body)
  "Run BODY with no theme enabled and restore the enabled themes afterwards."
  (declare (indent 0))
  `(eink-themes-test--call-with-clean-themes (lambda () ,@body)))

;;;; Color helpers

(defun eink-themes-test--strings (object)
  "Return all strings in OBJECT, a tree of lists and vectors."
  (cond ((stringp object) (list object))
        ((consp object)
         (append (eink-themes-test--strings (car object))
                 (eink-themes-test--strings (cdr object))))
        ((vectorp object) (eink-themes-test--strings (append object nil)))))

(defun eink-themes-test--color-string-p (string)
  "Return non-nil if STRING is a color: a hex triplet or a color name."
  (or (string-prefix-p "#" string)
      (and (assoc (tty-color-canonicalize string) color-name-rgb-alist) t)))

(defun eink-themes-test--colors (object)
  "Return all strings in OBJECT that are colors."
  (cl-remove-if-not #'eink-themes-test--color-string-p
                    (eink-themes-test--strings object)))

(defun eink-themes-test--rgb (color)
  "Return the 8-bit (RED GREEN BLUE) values of COLOR, or nil if unknown."
  (if (string-prefix-p "#" color)
      (let ((digits (length (substring color 1))))
        (when (and (memq digits '(3 6 9 12))
                   (string-match-p "\\`#[0-9a-fA-F]+\\'" color))
          (let ((size (/ digits 3)))
            (cl-loop for index from 0 below 3
                     for start = (+ 1 (* index size))
                     collect (/ (* 255 (string-to-number
                                        (substring color start (+ start size))
                                        16))
                                (1- (expt 16 size)))))))
    (when-let* ((entry (assoc (tty-color-canonicalize color)
                              color-name-rgb-alist)))
      (mapcar (lambda (value) (/ value 257)) (cdr entry)))))

(defun eink-themes-test--gray-level-p (color)
  "Return non-nil if COLOR is one of the 16 gray levels."
  (pcase (eink-themes-test--rgb color)
    (`(,red ,green ,blue)
     (and (= red green blue) (zerop (% red 17))))))

(defun eink-themes-test--theme-colors-gray-p (color)
  "Return non-nil if COLOR is a \"#RRGGBB\" string on a gray level."
  (and (string-match-p "\\`#[0-9a-fA-F]\\{6\\}\\'" color)
       (eink-themes-test--gray-level-p color)))

;;;; Theme helpers

(defun eink-themes-test--face-specs (theme)
  "Return an alist of (FACE . SPEC) for the faces THEME sets."
  (cl-loop for (type name _theme spec) in (get theme 'theme-settings)
           when (eq type 'theme-face)
           collect (cons name spec)))

(defun eink-themes-test--report (message offenders)
  "Fail the current test with MESSAGE and the list of OFFENDERS."
  (when offenders
    (ert-fail (format "%s (%d):\n%s" message (length offenders)
                      (mapconcat (lambda (offender) (format "  %S" offender))
                                 offenders "\n")))))

(defun eink-themes-test--palette-bindings (palette)
  "Return `let' bindings for the colors of PALETTE."
  (mapcar (lambda (color) (list (car color) (cdr color))) palette))

;;;; Basic behavior

(ert-deftest eink-themes-test-load-and-disable ()
  (eink-themes-test--with-clean-themes
    (dolist (theme eink-themes-test--themes)
      (load-theme theme t)
      (should (memq theme custom-enabled-themes))
      (disable-theme theme)
      (should-not (memq theme custom-enabled-themes)))))

(ert-deftest eink-themes-test-toggle ()
  (eink-themes-test--with-clean-themes
    (eink-themes-toggle)
    (should (equal custom-enabled-themes '(eink-light)))
    (eink-themes-toggle)
    (should (equal custom-enabled-themes '(eink-dark)))
    (eink-themes-toggle)
    (should (equal custom-enabled-themes '(eink-light)))))

(ert-deftest eink-themes-test-after-load-theme-hook ()
  (eink-themes-test--with-clean-themes
    (let* ((count 0)
           (eink-themes-after-load-theme-hook
            (list (lambda () (cl-incf count)))))
      (load-theme 'eink-light t)
      (should (= count 1))
      (eink-themes-toggle)
      (should (= count 2))
      (load-theme 'wombat t)
      (should (= count 2)))))

(ert-deftest eink-themes-test-theme-load-path ()
  (should (member (file-name-as-directory eink-themes-test--root)
                  (mapcar #'file-name-as-directory
                          (cl-remove-if-not #'stringp custom-theme-load-path)))))

(ert-deftest eink-themes-test-get-color ()
  (should (equal (eink-themes-get-color 'fg2 'light) "#666666"))
  (should (equal (eink-themes-get-color 'fg2 'dark) "#bbbbbb"))
  (should-error (eink-themes-get-color 'no-such-color 'light))
  (eink-themes-test--with-clean-themes
    (should-error (eink-themes-get-color 'fg0) :type 'user-error)
    (load-theme 'eink-dark t)
    (should (equal (eink-themes-get-color 'bg0) "#000000"))
    (should (equal (eink-themes-get-color 'bg0 'light) "#ffffff"))))

(ert-deftest eink-themes-test-default-colors ()
  (pcase-dolist (`(,theme ,foreground ,background)
                 '((eink-light "#000000" "#ffffff")
                   (eink-dark "#ffffff" "#000000")))
    (eink-themes-test--with-clean-themes
      (load-theme theme t)
      (let ((spec (cdar (alist-get 'default
                                   (eink-themes-test--face-specs theme)))))
        (should (equal (plist-get spec :foreground) foreground))
        (should (equal (plist-get spec :background) background))))))

;;;; Theme contents

(ert-deftest eink-themes-test-palettes-are-gray ()
  (dolist (palette (list eink-themes-light-palette eink-themes-dark-palette))
    (pcase-dolist (`(,name . ,color) palette)
      (should (eink-themes-test--theme-colors-gray-p color))
      (should (symbolp name)))
    (should (equal (mapcar #'car palette)
                   (mapcar #'car eink-themes-light-palette)))))

(ert-deftest eink-themes-test-every-color-is-a-gray-level ()
  (dolist (theme eink-themes-test--themes)
    (eink-themes-test--with-clean-themes
      (load-theme theme t)
      (let ((settings (get theme 'theme-settings))
            offenders)
        (should (> (length settings) 1000))
        (dolist (setting settings)
          (dolist (color (eink-themes-test--colors (nthcdr 3 setting)))
            (unless (eink-themes-test--theme-colors-gray-p color)
              (push (list (nth 1 setting) color) offenders))))
        (eink-themes-test--report
         (format "%s uses colors that are not gray levels" theme)
         (nreverse offenders))))))

(ert-deftest eink-themes-test-only-plain-display-specs ()
  (dolist (theme eink-themes-test--themes)
    (eink-themes-test--with-clean-themes
      (load-theme theme t)
      (eink-themes-test--report
       (format "%s has face specs that are not ((t ...))" theme)
       (cl-loop for (face . spec) in (eink-themes-test--face-specs theme)
                unless (and (= (length spec) 1) (eq (caar spec) t))
                collect face)))))

(ert-deftest eink-themes-test-no-height-changes ()
  (dolist (theme eink-themes-test--themes)
    (eink-themes-test--with-clean-themes
      (load-theme theme t)
      (eink-themes-test--report
       (format "%s sets :height" theme)
       (cl-loop for (face . spec) in (eink-themes-test--face-specs theme)
                when (memq :height (flatten-tree spec))
                collect face)))))

(ert-deftest eink-themes-test-icon-faces-have-no-foreground ()
  "Icons must take the color of the text around them.
Otherwise an icon on an inverted background, such as the major mode
icon in the active mode line, becomes unreadable."
  (dolist (theme eink-themes-test--themes)
    (eink-themes-test--with-clean-themes
      (load-theme theme t)
      (eink-themes-test--report
       (format "%s sets an icon foreground" theme)
       (cl-loop for (face . spec) in (eink-themes-test--face-specs theme)
                when (and (string-match-p
                           (rx bos (or "nerd-icons-" "all-the-icons-"
                                       "treemacs-all-the-icons-"))
                           (symbol-name face))
                          (not (string-match-p
                                (rx "ibuffer-" (or "dir" "file" "mode" "size")
                                    "-face" eos)
                                (symbol-name face)))
                          (memq :foreground (flatten-tree spec)))
                collect face)))))

(ert-deftest eink-themes-test-no-face-is-set-twice ()
  (let* ((bindings (eink-themes-test--palette-bindings
                    eink-themes-light-palette))
         (faces (cl-loop for section in eink-themes--faces
                         append (mapcar #'car
                                        (eval `(let ,bindings ,section) t))))
         (seen (make-hash-table :test #'eq))
         duplicates)
    (dolist (face faces)
      (if (gethash face seen)
          (push face duplicates)
        (puthash face t seen)))
    (eink-themes-test--report "Faces set more than once" duplicates)))

(ert-deftest eink-themes-test-no-hex-literals-outside-palettes ()
  (dolist (file '("eink-themes.el" "eink-light-theme.el" "eink-dark-theme.el"))
    (with-temp-buffer
      (insert-file-contents (expand-file-name file eink-themes-test--root))
      (delay-mode-hooks (emacs-lisp-mode))
      (goto-char (point-min))
      (while (re-search-forward
              "^(defconst eink-themes-\\(?:light\\|dark\\)-palette" nil t)
        (goto-char (match-beginning 0))
        (let ((start (point)))
          (forward-sexp)
          (delete-region start (point))))
      (goto-char (point-min))
      (let ((case-fold-search t))
        (should-not (re-search-forward "#[0-9a-f]\\{3,\\}" nil t))))))

;;;; Leaks of default face colors

(defun eink-themes-test--default-colors (face)
  "Return the colors in the default spec of FACE that are not gray levels."
  (cl-remove-if #'eink-themes-test--gray-level-p
                (eink-themes-test--colors (face-default-spec face))))

(defun eink-themes-test--leaks (theme)
  "Return (FACE . COLORS) for faces whose default spec leaks colors.
Only faces that THEME does not set are checked, because a theme spec
replaces the default spec of a face."
  (let ((themed (make-hash-table :test #'eq)))
    (pcase-dolist (`(,face . ,_) (eink-themes-test--face-specs theme))
      (puthash face t themed))
    (cl-loop for face in (sort (face-list) #'string<)
             for colors = (and (not (gethash face themed))
                               (eink-themes-test--default-colors face))
             when colors collect (cons face colors))))

(defun eink-themes-test--require-libraries (libraries)
  "Require each of LIBRARIES and return the ones that could not be loaded.
Prompts that a library may show are answered with no."
  (cl-letf (((symbol-function 'y-or-n-p) #'ignore)
            ((symbol-function 'yes-or-no-p) #'ignore))
    (cl-loop for library in libraries
             unless (condition-case nil
                        (require library nil t)
                      (error nil))
             collect library)))

(defun eink-themes-test--check-leaks ()
  "Fail if a face that either theme leaves alone has a colored default spec."
  (dolist (theme eink-themes-test--themes)
    (eink-themes-test--with-clean-themes
      (load-theme theme t)
      (eink-themes-test--report
       (format "%s leaves faces whose default spec has colors" theme)
       (eink-themes-test--leaks theme)))))

(ert-deftest eink-themes-test-no-leaks-in-builtin-libraries ()
  (message "Built-in libraries that did not load: %S"
           (eink-themes-test--require-libraries
            eink-themes-test--builtin-libraries))
  (eink-themes-test--check-leaks))

(defvar eink-themes-test-popular-packages)

(ert-deftest eink-themes-test-no-leaks-in-popular-packages ()
  (skip-unless (getenv "EINK_THEMES_TEST_FULL"))
  (message "Built-in libraries that did not load: %S"
           (eink-themes-test--require-libraries
            eink-themes-test--builtin-libraries))
  (message "Packages that did not load: %S"
           (eink-themes-test--require-libraries
            eink-themes-test-popular-packages))
  (eink-themes-test--check-leaks))

(provide 'eink-themes-test)

;;; eink-themes-test.el ends here
