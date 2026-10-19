# eink.el

Two Emacs themes, `eink-light` and `eink-dark`, for real e-ink displays: Boox
and reMarkable-style tablets, Dasung/Onyx monitors, Kindle-class panels. They
are not a "paper look" theme for LCD screens.

## Why a separate theme for e-ink

- Most panels show 16 gray levels. Any other color is dithered, and dithered
  text looks fuzzy. Color panels (Kaleido) are low-saturation and low-resolution,
  so hue is a poor way to carry information.
- Large gray areas look blotchy and ghost when they move. Backgrounds are used
  only where they help you find something: selection, search, the cursor, the
  selected completion candidate, diffs.
- Thin, light text disappears. Text you read is near black (or white on dark),
  and decoration is never lighter than level 8 (`#888888`) on light.
- Font style works well: bold, italic, underline, the underline shapes (wave,
  dots, dashes, double line) and boxes.

So eink.el follows these rules:

1. **Grayscale only.** Every color is one of the 16 gray levels (`#RRGGBB` with
   `R == G == B`, each channel a multiple of `0x11`). That includes terminal
   colors and package faces.
2. **Style carries meaning, not hue.** Gray level orders importance; bold,
   italic, underline shape and boxes tell kinds of things apart.
3. **Few backgrounds.** Popups use at most a faint fill and a visible border.
   Source blocks have no background.
4. **Inversion for "you are here".** The cursor, the current search match, the
   active mode line, the selected tab and jump labels are drawn with the
   background and foreground swapped.
5. **No height changes.** Headings differ by weight and underline, so text does
   not reflow when headings scroll by.

The themes cover the built-in libraries and many popular packages (Org, Magit,
Markdown, Vertico, Corfu, Consult, Embark, Flymake, Flycheck, Eglot, Evil,
doom-modeline, vterm, eat, and more). Faces that a package defines with colors
are all set, so no stray color shows up on the panel.

## Installation

Emacs 30.1 or later is required.

With `package-vc` and `use-package`:

```elisp
(use-package eink-themes
  :vc (:url "https://github.com/milanglacier/eink.el")
  :config
  (load-theme 'eink-light t))
```

With straight.el:

```elisp
(straight-use-package
 '(eink-themes :type git :host github :repo "milanglacier/eink.el"))
```

From a local checkout:

```elisp
(add-to-list 'load-path "/path/to/eink.el")
(require 'eink-themes)
```

## Usage

Load a theme:

```elisp
(load-theme 'eink-light t)
;; or
(load-theme 'eink-dark t)
```

`M-x eink-themes-toggle` switches between the two themes. It loads
`eink-light` when neither is enabled. Bind it to a key if you switch often:

```elisp
(global-set-key (kbd "C-c t") #'eink-themes-toggle)
```

`eink-themes-after-load-theme-hook` runs after either theme is enabled:

```elisp
(add-hook 'eink-themes-after-load-theme-hook
          (lambda () (message "eink theme enabled")))
```

### Palette colors

`eink-themes-get-color` returns a palette color as a `#RRGGBB` string. It uses
the enabled eink theme, or the variant you pass (`light` or `dark`):

```elisp
(eink-themes-get-color 'fg2)         ; color of the enabled eink theme
(eink-themes-get-color 'bg1 'dark)   ; color of the dark theme
```

| name  | role                                          | light     | dark      |
|-------|-----------------------------------------------|-----------|-----------|
| `bg0` | main background                               | `#ffffff` | `#000000` |
| `bg1` | faint fill: current line, popups, inline code | `#eeeeee` | `#222222` |
| `bg2` | fill: region, inactive mode line, added lines | `#dddddd` | `#333333` |
| `bg3` | strong fill: search matches, selected candidate | `#bbbbbb` | `#555555` |
| `fg0` | main text                                     | `#000000` | `#ffffff` |
| `fg1` | secondary text: strings, punctuation          | `#444444` | `#dddddd` |
| `fg2` | comments, muted text                          | `#666666` | `#bbbbbb` |
| `fg3` | line numbers, separators, inactive text       | `#888888` | `#999999` |
| `fg4` | whitespace marks, indent guides               | `#aaaaaa` | `#777777` |

The palette also has `term-black`, `term-red`, ..., `term-bright-white` for the
16 terminal colors.

### Changing a face

There are no options for bold, italic or colors. To change a face, use the
usual Emacs mechanisms. Use `eink-themes-get-color` to stay on the gray levels:

```elisp
(custom-theme-set-faces
 'user
 `(font-lock-comment-face ((t :foreground ,(eink-themes-get-color 'fg3)))))
```

## Development

```sh
make compile           # byte-compile with warnings as errors
make lint              # byte-compile, checkdoc and package-lint
make test              # run the ERT tests
make test-full         # also check popular third-party packages
make clean-test-cache  # delete the downloaded packages
```

All targets run `emacs -Q`, so your own configuration is never loaded.
`make lint` and `make test-full` install their packages with `package.el`
into `.cache/emacs`.

## License

MIT
