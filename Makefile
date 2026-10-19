EMACS ?= emacs
SOURCES = eink-themes.el eink-light-theme.el eink-dark-theme.el
TESTS = tests/eink-themes-test.el
EINK_THEMES_TEST_EMACS_DIR ?= $(CURDIR)/.cache/emacs
export EINK_THEMES_TEST_EMACS_DIR

BATCH = $(EMACS) -Q --batch -L . --eval '(setq load-prefer-newer t)'
# Like BATCH, with packages installed by package.el into
# EINK_THEMES_TEST_EMACS_DIR.
PACKAGE_BATCH = $(BATCH) -l tests/test-helper.el

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

.PHONY: compile test test-full lint clean clean-test-cache

compile:
	$(BATCH) --eval '(setq byte-compile-error-on-warn t)' \
	  -f batch-byte-compile $(SOURCES)

test:
	$(BATCH) -l $(TESTS) -f ert-run-tests-batch-and-exit

# Also check the popular third-party packages listed in
# tests/test-helper.el.
test-full:
	EINK_THEMES_TEST_FULL=1 $(PACKAGE_BATCH) \
	  --eval '(eink-themes-test-ensure-packages eink-themes-test-popular-packages)' \
	  -l $(TESTS) -f ert-run-tests-batch-and-exit

lint: compile
	$(BATCH) --eval "$$CHECKDOC" $(SOURCES) $(TESTS) tests/test-helper.el
	$(PACKAGE_BATCH) \
	  --eval "(eink-themes-test-ensure-packages '(package-lint))" \
	  --eval "(require 'package-lint)" \
	  --eval '(setq package-lint-main-file "eink-themes.el")' \
	  -f package-lint-batch-and-exit $(SOURCES)

clean:
	rm -f $(SOURCES:.el=.elc)

clean-test-cache:
	rm -rf "$(EINK_THEMES_TEST_EMACS_DIR)"
