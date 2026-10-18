EMACS ?= emacs
SOURCES = eink-themes.el eink-light-theme.el eink-dark-theme.el
TESTS = tests/eink-themes-test.el
STRAIGHT_BUILD ?= $(HOME)/.config/emacs/straight/build

BATCH = $(EMACS) -Q --batch -L . --eval '(setq load-prefer-newer t)'

# Report every checkdoc warning, then exit with an error if there was one.
define CHECKDOC
(progn
  (require 'checkdoc)
  (dolist (file command-line-args-left)
    (checkdoc-file file))
  (setq command-line-args-left nil)
  (when (get-buffer "*Warnings*")
    (kill-emacs 1)))
endef
export CHECKDOC

.PHONY: compile test test-extra lint clean

compile:
	$(BATCH) --eval '(setq byte-compile-error-on-warn t)' \
	  -f batch-byte-compile $(SOURCES)

test:
	$(BATCH) -l $(TESTS) -f ert-run-tests-batch-and-exit

# Also check the third-party packages installed in the straight build
# directories.
test-extra:
	@EINK_THEMES_EXTRA_LOAD_PATH='$(shell printf '%s:' $(STRAIGHT_BUILD)/*)' \
	  $(MAKE) --no-print-directory test

lint: compile
	$(BATCH) --eval "$$CHECKDOC" $(SOURCES) $(TESTS)

clean:
	rm -f $(SOURCES:.el=.elc)
