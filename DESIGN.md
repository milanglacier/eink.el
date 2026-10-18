# eink.el design

eink.el provides two Emacs themes, `eink-light` and `eink-dark`, for running
Emacs on a real e-ink display (Boox, reMarkable-style tablets, Dasung/Onyx
monitors, Kindle-class panels). It is not a "paper look" theme for LCD
screens. Every decision below follows from how e-ink panels behave.

The breadth of face coverage follows the built-in `modus-operandi` and
`modus-vivendi` themes (`etc/themes/modus-themes.el` in the Emacs source).
The machinery does not: there are exactly two variants, no palette overrides,
no presets, and almost no options.

## Constraints of e-ink panels

1. Most panels show 16 gray levels. Any color that is not one of those levels
   is dithered, and dithered text looks fuzzy. Color panels (Kaleido) show low
   saturation at low resolution, so hue is a poor way to carry information.
2. Large gray areas look blotchy and leave ghosting when they move
   (`hl-line`, popup backgrounds, scrolling). Use filled backgrounds only where
   they help the user find something: region, search, cursor, the selected
   completion candidate, diffs.
3. Thin, light text disappears. Text you must read is near black, and
   decoration is never lighter than level 8 (`#888888`) on light.
4. Font style works well on e-ink: **bold**, *italic*, underline, and the
   underline styles Emacs 30 supports on GUI frames: `line`, `double-line`,
   `wave`, `dots`, `dashes`. Boxes (`:box`) also render crisply.

## Rules

- **Grayscale only.** Every color is `#RRGGBB` with `R == G == B` and each
  channel a multiple of `0x11`, so it maps exactly onto one of the 16 gray
  levels. No other color appears anywhere in the theme: faces, custom
  variables, ANSI colors, fringe bitmaps. Hex literals appear only in the
  palette definition.
- **Style carries meaning, not hue.** Gray level orders importance. Bold,
  italic, underline style and box tell kinds of things apart.
- **Few backgrounds.** Child frames and popups get at most `bg1` and a visible
  border. Org source blocks, markdown code blocks and similar get no
  background; their begin/end lines mark them.
- **Inversion for "you are here".** The cursor, the current isearch match, the
  active mode line, the selected tab and jump labels (avy, ace-window) use
  inverted colors (`bg0` on `fg0`). Inversion is the clearest highlight an
  e-ink panel can show.
- **No height changes.** Every face keeps `:height` unset (1.0). Headings
  differ by weight and underline, so text does not reflow and the panel does
  not need a full refresh when headings scroll by.
- **Every colored default face is covered.** If a library defines a face
  whose default spec has a color, the theme must set that face, otherwise the
  library's red or blue leaks onto the panel. The leak test (see Tests)
  enforces this for built-in libraries and, optionally, for installed
  third-party packages.

## Palette

The names are semantic so that one face table works for both variants.

| name  | role                                         | light     | dark      |
|-------|----------------------------------------------|-----------|-----------|
| `bg0` | main background                              | `#ffffff` | `#000000` |
| `bg1` | faint fill: hl-line, popups, inline code     | `#eeeeee` | `#222222` |
| `bg2` | fill: region, inactive mode line, diff added | `#dddddd` | `#333333` |
| `bg3` | strong fill: lazy-highlight, selected candidate, refined diff | `#bbbbbb` | `#555555` |
| `fg0` | main text                                    | `#000000` | `#ffffff` |
| `fg1` | secondary text: strings, punctuation         | `#444444` | `#bbbbbb` |
| `fg2` | comments, muted UI text                      | `#666666` | `#999999` |
| `fg3` | line numbers, separators, inactive           | `#888888` | `#777777` |
| `fg4` | non-text, whitespace, indent guides          | `#aaaaaa` | `#555555` |

There are no other colors. `unspecified` is allowed.

## Syntax (font-lock)

Emacs 29+ tree-sitter modes use the same `font-lock-*` faces, so this table
covers both.

| face | style |
|---|---|
| `font-lock-comment-face`, `-comment-delimiter-face` | `fg2` italic |
| `font-lock-doc-face` | `fg2` italic |
| `font-lock-doc-markup-face` | `fg2` bold italic |
| `font-lock-keyword-face` | `fg0` bold |
| `font-lock-preprocessor-face` | `fg0` bold |
| `font-lock-negation-char-face` | `fg0` bold |
| `font-lock-function-name-face` (definitions) | `fg0` bold |
| `font-lock-function-call-face` | `fg0` |
| `font-lock-builtin-face` | `fg0` |
| `font-lock-type-face` | `fg0` |
| `font-lock-variable-name-face`, `-variable-use-face` | `fg0` |
| `font-lock-property-name-face`, `-property-use-face` | `fg0` |
| `font-lock-constant-face`, `-number-face` | `fg0` italic |
| `font-lock-string-face` | `fg1` |
| `font-lock-escape-face`, `-regexp-face`, `-regexp-grouping-backslash`, `-regexp-grouping-construct` | `fg1` bold |
| `font-lock-operator-face` | `fg0` |
| `font-lock-bracket-face`, `-delimiter-face`, `-punctuation-face`, `-misc-punctuation-face` | `fg1` |
| `font-lock-warning-face` | `fg0` bold |

Related: `elisp-shorthand-font-lock-face` `fg0` italic; `highlight-quoted-symbol`
`fg0` italic, `highlight-quoted-quote` `fg1`. Emacs 31's elisp semantic
highlighting faces (`elisp-*` in `elisp-mode.el`, e.g. function, macro,
special form, variable, binding, face, symbol-role faces) follow the same
logic: definitions/bindings bold, macros and special forms bold, constants and
keywords italic, everything else `fg0`, unknown/free symbols `fg0` with a
`dots` underline in `fg3`.

`hl-todo-keyword-faces` (a custom variable): every keyword `fg0` bold on
`bg2`, no per-keyword distinction.

`rainbow-delimiters-depth-N-face`: alternate `fg0` and `fg1`, odd depths bold.
`rainbow-delimiters-unmatched-face` and `-mismatched-face`: `fg0` bold with a
`wave` underline.

## Core UI

| face | style |
|---|---|
| `default` | `fg0` on `bg0` |
| `cursor` | background `fg0` |
| `fringe` | `fg3` on `bg0` |
| `vertical-border`, `window-divider*`, `internal-border`, `child-frame-border`, `border` | `fg3` (as foreground or background as the face needs) |
| `hl-line` | `bg1`, `:extend t` |
| `region` | `bg2`, `:extend t`, foreground unspecified |
| `secondary-selection` | `bg1` with `dots` underline `fg3`, `:extend t` |
| `highlight` | `bg2` |
| `shadow` | `fg2` |
| `minibuffer-prompt` | `fg0` bold |
| `link` | `fg0` underline. `link-visited`: `fg1` underline `dashes` |
| `button` | `fg0` underline |
| `error` | `fg0` bold. `warning`: `fg0` bold. `success`: `fg0` bold italic |
| `escape-glyph`, `homoglyph`, `nobreak-*`, `glyphless-char` | `fg1` bold |
| `trailing-whitespace` | background `bg3` |
| `line-number` | `fg3` on `bg0`. `line-number-current-line`: `fg0` bold on `bg0`. major/minor tick: `fg2` bold |
| `fill-column-indicator` | `fg4` |
| `mode-line`, `mode-line-active` | inverted (`bg0` on `fg0`), box 1px `fg0` |
| `mode-line-inactive` | `fg0` on `bg2`, box 1px `bg2` |
| `mode-line-buffer-id` | bold. `mode-line-emphasis`: bold italic. `mode-line-highlight`: box `fg3` |
| `header-line` | `fg0` on `bg1`. `header-line-inactive` (31): `fg2` on `bg1`. `header-line-highlight`: box `fg3` |
| `tab-bar` | `fg0` on `bg1`. `tab-bar-tab`: inverted bold. `tab-bar-tab-inactive`: `fg2` on `bg1`. groups follow the same pattern |
| `tab-line` | same as `tab-bar`; `tab-line-tab-current` inverted bold, `tab-line-tab-modified` italic |
| `tooltip` | `fg0` on `bg1` |
| `menu`, `tty-menu-*` | `fg0` on `bg1`; selected item inverted |
| `help-key-binding` | `fg0` bold on `bg1`, box 1px `fg3` |
| `show-paren-match` | `fg0` bold underline on `bg2` |
| `show-paren-match-expression` | `bg1` |
| `show-paren-mismatch` | inverted, `wave` underline |
| `separator-line` | `fg3`, underline |

### Search and replace

| face | style |
|---|---|
| `isearch` | inverted bold |
| `lazy-highlight` | `fg0` on `bg3` |
| `isearch-fail` | `fg0` bold on `bg2` with `wave` underline |
| `isearch-group-1`, `-2` | inverted bold, plus underline / `double-line` underline |
| `match` | `fg0` bold on `bg2` |
| `query-replace` | inverted bold |
| `replace-*` faces of `re-builder` (`reb-match-0..3`) | `bg2`, `bg3`, `bg2` underline, `bg3` underline |

### Completion

Selected candidate: `fg0` bold on `bg3`, `:extend t`. Do not invert:
completion UIs draw match highlights and icons with their own foreground,
which an inverted row would hide.

Match highlight: matched characters are bold and underlined. Orderless
components differ by underline style so you can still tell them apart:
`orderless-match-face-0` bold `line` underline, `-1` bold `double-line`,
`-2` bold `dots`, `-3` bold `dashes`. Same idea for
`completions-common-part` (bold underline) and
`completions-first-difference` (bold).

Popups (`corfu-default`, `company-tooltip`, `completion-preview`): `fg0` on
`bg1`, border `fg3`, scrollbar thumb `fg3` on `bg2`.
`completion-preview`: `fg2` italic, `completion-preview-exact`: `fg2` italic
underline. Annotations (`marginalia-*`, `completions-annotations`,
`corfu-annotations`): `fg2`, documentation-like ones italic; key bindings
`fg0` bold; file sizes/dates `fg2`. Group titles (`vertico-group-title`,
`completions-group-title`): `fg2` bold italic, separators `fg3`
strike-through.

### Diagnostics (flymake, flycheck, eglot, flyspell, jinx)

Severity shows through underline style and weight, not hue.

| severity | in-buffer underline | fringe / echo text |
|---|---|---|
| error | `wave` `fg0` | `fg0` bold |
| warning | `line` `fg0` | `fg0` |
| note / info | `dots` `fg1` | `fg1` |
| hint | `dashes` `fg2` | `fg2` |

Spelling (`flyspell-incorrect`, `jinx-misspelled`, `spell-fu-incorrect-face`):
`wave` `fg2`. `flyspell-duplicate`: `dots` `fg2`. Eglot:
`eglot-highlight-symbol-face` `bg2` bold (and the eglot read/write variants),
`eglot-inlay-hint-face` `fg3` italic (do not shrink it),
`eglot-diagnostic-tag-unnecessary-face` `fg3`,
`eglot-diagnostic-tag-deprecated-face` strike-through.
`eldoc-highlight-function-argument`: bold underline.

## Prose and markup

### Headings

Applies to `outline-1..8`, `org-level-1..8`, `markdown-header-face-1..6`,
`info-title-1..4`, `shr-h1..6`, `info` and `Man` headers.

| level | style |
|---|---|
| 1 | `fg0` bold, `double-line` underline |
| 2 | `fg0` bold, `line` underline |
| 3 | `fg0` bold |
| 4 | `fg0` bold italic |
| 5–8 | `fg1` bold |

`org-document-title`: `fg0` bold, `double-line` underline. `org-document-info`:
`fg1`. `org-document-info-keyword`, `org-meta-line`, `org-special-keyword`,
`org-drawer`, `org-property-value`: `fg2`.

### Org

- `org-todo`: `fg0` bold, box 1px `fg0`. `org-done`: `fg2` bold, box 1px
  `fg3`. `org-headline-done`: `fg2`. `org-headline-todo`: unspecified.
- `org-priority`: `fg0` bold. `org-tag`: `fg2` italic. `org-checkbox`: `fg0`
  bold. `org-checkbox-statistics-todo`: `fg0` bold.
  `org-checkbox-statistics-done`: `fg2`.
- `org-code`, `org-verbatim`: `fg1` on `bg1`. `org-block`: `fg0`, no
  background, `:extend t`. `org-block-begin-line`, `org-block-end-line`:
  `fg2` italic, underline / overline `fg4`, `:extend t`. `org-quote`,
  `org-verse`: `fg1` italic.
- `org-link`: `fg0` underline. `org-footnote`: `fg1` underline `dots`.
  `org-target`: underline. `org-date`: `fg1` underline `dots`.
  `org-sexp-date`: same.
- `org-table`, `org-formula`: `fg1`. `org-table-header`: `fg0` bold on `bg1`.
- `org-latex-and-related`: `fg0` italic. `org-macro`: `fg0` italic.
- `org-ellipsis`: `fg2`. `org-hide`: `bg0` (foreground).
- Agenda: `org-agenda-structure` `fg0` bold double underline,
  `org-agenda-date` `fg0` bold, `org-agenda-date-today` inverted bold,
  `org-agenda-date-weekend` `fg1` bold, `org-scheduled` `fg0`,
  `org-scheduled-today` `fg0` bold, `org-scheduled-previously` `fg0` italic,
  `org-upcoming-deadline` `fg0` italic, `org-imminent-deadline` and
  `org-warning` `fg0` bold underline, `org-time-grid` `fg3`,
  `org-agenda-current-time` `fg0` bold, `org-agenda-done` `fg2`,
  `org-agenda-dimmed-todo-face` `fg3`, `org-agenda-clocking` `bg2`.
- `org-habit-*`: no hue. ready `bg3`, clear `bg1`, alert `fg3` (background),
  overdue `fg0` (background); the future variants one step lighter (`bg2`,
  `bg0`, `bg3`, `fg2`).
- `org-mode-line-clock`: unspecified; `org-mode-line-clock-overrun`: bold.
- org-roam and org-appear faces where they exist: same rules.

### Markdown

`markdown-bold-face` bold, `-italic-face` italic, `-strike-through-face`
`fg2` strike-through, `-inline-code-face` `fg1` on `bg1`, `-code-face` and
`-pre-face` `fg1` no background, `-markup-face`, `-header-delimiter-face`,
`-list-face` (bold), `-blockquote-face` `fg1` italic, links and URLs
underline, `-url-face` `fg1` underline, `-reference-face` `fg2`,
`-html-*` `fg1`, `-highlighting-face` `bg3`, `-gfm-checkbox-face` bold.

### Info, help, man, shortdoc, eww/shr

- `info-menu-star` `fg0`, `info-node` bold italic, `info-xref` `fg0`
  underline, `info-xref-visited` `fg1` underline `dashes`,
  `info-header-node` and `info-header-xref` bold, `info-index-match` `bg3`.
- `Man-overstrike` and `woman-bold` bold, `Man-underline` and `woman-italic`
  underline italic, `Man-reverse` inverted.
- `help-argument-name` italic, `help-for-help-header` bold.
  `helpful-heading` bold underline.
- `shortdoc-heading` bold double underline, `shortdoc-section` `bg1`.
- `shr-*`: link underline, `shr-code` `fg1` on `bg1`, `shr-mark` `bg3`,
  `shr-strike-through` strike-through `fg2`, `shr-sup` unspecified.
  `eww-form-*`: box `fg3`, text `fg0`, `eww-valid-certificate` bold,
  `eww-invalid-certificate` bold `wave`.

### Mail and feeds

`message-header-name` `fg2`, `-subject` `fg0` bold, `-to`/`-cc` `fg0`,
`-other` `fg1`, `-separator` `fg3`, `-xheader` `fg2`, `-signature` and
`message-cited-text-1..4` alternate `fg1` / `fg2` italic, `message-mml`
`fg2` italic. `gnus-header-*` mirror these. `notmuch-*`: search date `fg2`,
count `fg2`, authors `fg0`, subject `fg0`, matching tags `fg1` italic,
`notmuch-search-unread-face` bold, `notmuch-search-flagged-face` underline,
`notmuch-tag-*` italic, `notmuch-message-summary-face` bold on `bg1`,
`notmuch-wash-cited-text` `fg2` italic. `elfeed-search-*`: date `fg2`,
title `fg0`, unread title bold, feed `fg1`, tag `fg2` italic.
`org-msg` uses the org faces.

## Version control and diffs

The same rule everywhere (diff-mode, magit, ediff, smerge, vc):

| what | style |
|---|---|
| added line | `fg0` on `bg2` |
| removed line | `fg2` italic, no background |
| changed line | `fg0` italic |
| refined added (word level) | `fg0` bold on `bg3` |
| refined removed | `fg1` strike-through on `bg2` |
| context | `fg1` |
| indicator `+` / `-` | `fg0` bold |
| hunk header | `fg2` bold on `bg1` |
| file header | `fg0` bold on `bg2` |

Magit: the `*-highlight` variants of each face are the same, except context
highlight gets `bg1`; `magit-section-highlight` `bg1`;
`magit-section-heading` `fg0` bold underline; `magit-branch-local` bold,
`magit-branch-remote` bold italic, `magit-branch-current` bold box `fg0`,
`magit-tag` italic, `magit-hash` `fg2`, `magit-dimmed` `fg3`,
`magit-log-author` `fg1`, `magit-log-date` `fg2`, `magit-process-ok` bold,
`magit-process-ng` bold `wave`, `magit-diff-*-highlight` per table,
`magit-blame-*` `fg2` on `bg1`, `magit-signature-*` bold / italic,
`magit-bisect-*` bold / italic / strike-through, `magit-reflog-*` and
`magit-sequence-*` and `magit-cherry-*` use bold / italic / `fg2`, never hue.
`git-commit-summary` bold, `git-commit-overlong-summary` `wave`,
`git-commit-nonempty-second-line` `wave`, `git-commit-comment-*` `fg2`.
`git-rebase-*` follows magit.

Ediff: current diff A/B/C `fg0` on `bg2`, fine diff `fg0` bold on `bg3`, odd
and even diffs `bg1`, ancestor variants the same.

smerge: `smerge-upper` = removed, `smerge-lower` = added, `smerge-base`
`bg1`, `smerge-markers` `fg2` bold on `bg1`, refined as in the table.

Fringe and margin indicators (`diff-hl-*`, `git-gutter*`):
insert solid `fg0` (foreground and background), change solid `bg3`, delete
solid `fg3`. Three clearly separate gray levels.

`vc-*` mode-line state faces: `vc-up-to-date-state` unspecified,
`vc-edited-state` italic, `vc-locally-added-state` bold,
`vc-conflict-state` and `vc-missing-state` bold `wave`,
`vc-removed-state` strike-through. `log-view-*` and `change-log-*`: names
bold, dates `fg2`, files `fg0` bold.

## Files and buffers

- dired: `dired-directory` `fg0` bold, `dired-symlink` `fg0` italic,
  `dired-broken-symlink` `fg0` italic `wave`, `dired-header` bold underline,
  `dired-mark` bold, `dired-marked` inverted bold, `dired-flagged` `fg0`
  strike-through on `bg2`, `dired-perm-write` `fg1`, `dired-set-id` bold,
  `dired-special` italic, `dired-ignored` `fg3`, `dired-warning` bold.
- `diredfl-*`: dates/sizes `fg2`, permissions `fg1`, directory `fg0` bold,
  file name `fg0`, file suffix `fg1`, compressed/ignored `fg3`, deletion and
  flags as above. `dired-subtree-depth-N-face`: unspecified (no stripes).
  `dired-git-info` `fg2`.
- ibuffer, proced, package menu, bookmark, xref, grep, compilation, occur,
  ripgrep/wgrep: file names `fg0` bold, line numbers `fg3`, column numbers
  `fg3`, matches bold underline or `bg3`, `compilation-error` bold,
  `compilation-warning` bold italic, `compilation-info` `fg0`,
  `compilation-mode-line-fail` bold `wave`, `compilation-mode-line-exit`
  bold, `next-error` and `xref-match` `bg3`, `wgrep-face` `bg2`
  underline, `wgrep-delete-face` strike-through `fg2`, `wgrep-done-face`
  `fg2`. `package-status-*`: installed/built-in `fg0`, available `fg1`,
  new bold, obsolete/held `fg3` strike-through.
- nerd-icons (`nerd-icons-*` color faces), all-the-icons: every icon face
  `fg1`. Hue in icons carries nothing on e-ink.

## Terminal and ANSI

`ansi-color-*` (and `ansi-color-bright-*`), `term-color-*`, `vterm-color-*`,
`eat-term-color-0..15` and `ghostel` color faces where they exist map to:

- Light: black `#000000`, red `#333333`, green `#444444`, yellow `#444444`,
  blue `#333333`, magenta `#444444`, cyan `#333333`, white `#888888`;
  bright black `#666666`, bright red `#222222`, bright green `#333333`,
  bright yellow `#444444`, bright blue `#222222`, bright magenta `#333333`,
  bright cyan `#555555`, bright white `#aaaaaa`.
- Dark: black `#555555`, red `#cccccc`, green `#bbbbbb`, yellow `#dddddd`,
  blue `#cccccc`, magenta `#bbbbbb`, cyan `#dddddd`, white `#ffffff`;
  bright black `#777777`, bright red `#eeeeee`, bright green `#dddddd`,
  bright yellow `#eeeeee`, bright blue `#dddddd`, bright magenta `#cccccc`,
  bright cyan `#eeeeee`, bright white `#ffffff`.

Add these 16 as extra palette entries (`term-black` … `term-bright-white`)
in each variant so faces still reference names, not literals. Background
faces of ANSI colors use the same value. `ansi-color-bold` bold,
`ansi-color-italic` italic, etc.

`comint-highlight-prompt` `fg0` bold, `comint-highlight-input` bold.
`eshell-prompt` bold, `eshell-ls-directory` bold, `eshell-ls-symlink`
italic, `eshell-ls-executable` bold italic, `eshell-ls-archive` and other
types `fg1`, `eshell-ls-missing` `wave`, `eshell-ls-backup` `fg3`.
`pdf-view-midnight-colors` (custom variable): `(fg0 . bg0)` of the variant.

## Packages

Cover every face (that has a color in its default spec) of these. "Same
rules" means apply the sections above; pick the closest analogue.

Built in: the core faces above, font-lock, `ansi-color`, `bookmark`,
`calendar` and `diary` (today inverted, holiday bold, marked `bg2`),
`change-log`, `compilation`, `completion-preview`, `completions`
(minibuffer), `custom` (customize buffers: `custom-group-tag` bold double
underline, `custom-variable-tag` bold, `custom-state` italic,
`custom-changed` / `custom-modified` / `custom-set` / `custom-themed`
bold or italic on `bg1`, `custom-invalid` bold `wave`, `custom-button*`
box `fg3` on `bg1`), `diff-mode`, `dired`, `ediff`, `eglot`, `eldoc`, `epa`,
`ert` (`ert-test-result-expected` bold on `bg2`, unexpected inverted bold),
`eshell`, `eww` / `shr`, `flymake`, `flyspell`, `hexl`, `hi-lock` (the
`hi-*` faces: `hi-yellow`, `hi-pink`, `hi-green`, `hi-blue`,
`hi-salmon`, `hi-aquamarine` become `bg2`, `bg3`, `bg2` underline, `bg3`
underline, `bg2` box `fg3`, `bg3` box `fg3`; `hi-black-b` bold, `hi-black-hb`
bold, `hi-blue-b` bold underline, `hi-green-b` bold `double-line`,
`hi-red-b` bold `wave`), `hideshow`, `ibuffer`, `icomplete`, `info`,
`isearch`, `kmacro-menu`, `log-view`, `man` / `woman`, `message` / `gnus`
(article and header faces), `outline`, `package`, `proced`, `pulse`
(`pulse-highlight-start-face` and `-face` `bg3`), `re-builder`,
`ruler-mode`, `shortdoc`, `show-paren`, `smerge`, `speedbar`, `tab-bar`,
`tab-line`, `table`, `term`, `textsec`, `transient` (built in since 28),
`vc` / `vc-dir`, `which-func`, `which-key` (built in since 30),
`whitespace` (all marks `fg4`; `whitespace-tab` and `-space` `fg4` no
background; `whitespace-trailing`, `-line`, `-big-indent`,
`-space-before-tab`, `-space-after-tab`, `-indentation`, `-empty`,
`-missing-newline-at-eof` `fg0` on `bg3`), `widget` (`widget-field` `bg1`
box `fg3`, `widget-button` bold), `window-divider`, `xref`, `elisp-mode`
semantic faces (31), `org` (all of it incl. agenda and habit).

Third party (the user's set, plus common ones): anzu, avy (labels inverted
bold; `avy-lead-face-0/1/2` inverted bold with underline variants so
consecutive chars differ), ace-window (`aw-leading-char-face` inverted
bold), cape, citre, company and company-box, consult (`consult-preview-*`
`bg2`, `consult-highlight-match` bold underline, `consult-file` `fg0`,
`consult-bookmark`, `consult-buffer`, `consult-line-number*` `fg3`,
`consult-async-*` bold / italic, `consult-narrow-indicator` bold),
corfu, dape (breakpoint inverted, stack frame `bg2`), diff-hl,
dired-sidebar, diredfl, dired-git-info, doom-modeline (all
`doom-modeline-*`: buffer name bold, modified bold italic, project/dir
`fg1` bold, info/warning/urgent `fg0` bold with underline styles matching
severity, evil state faces all bold; bar `fg0` background active,
`bg2` inactive), eat, elfeed, embark (`embark-keybinding` bold box `fg3`,
`embark-target` `bg2`, `embark-collect-*` same rules), evil
(`evil-ex-info` bold, `evil-ex-substitute-matches` strike-through `fg2`,
`evil-ex-substitute-replacement` bold underline, `evil-ex-search` inverted
bold, `evil-ex-lazy-highlight` = lazy-highlight), evil-goggles (all `bg2`,
delete `bg3`), evil-snipe (first match inverted bold, matches bold
underline), evil-traces, flycheck, ghostel, git-gutter, helpful,
highlight-quoted, hl-todo, jinx, jupyter, macrostep (`macrostep-expansion-highlight-face`
`bg1`, gensym bold box `fg3`), magit (and magit-section, git-commit,
git-rebase, with-editor), marginalia, markdown-mode, minuet
(`minuet-suggestion-face` `fg3` italic), copilot (`copilot-overlay-face`
`fg3` italic), nerd-icons*, notmuch, orderless, org-roam, rainbow-delimiters,
rg / deadgrep, spacious-padding (`spacious-padding-subtle-mode-line-*`
foreground `fg3`), symbol-overlay (all `bg2`/`bg3`/box variants),
treemacs (dirs bold, files `fg0`, git states as VC), vertico (and
vertico-quick: labels inverted bold), vterm, vundo (`vundo-highlight` bold,
`vundo-saved` underline, `vundo-node` `fg2`), wgrep, which-key, yasnippet
(`yas-field-highlight-face` `bg2` underline), keycast (`keycast-key`
inverted bold, `keycast-command` bold), olivetti (fringe `bg0`), pdf-tools
(isearch faces + midnight colors), undo-tree, imenu-list, breadcrumb (`fg2`,
leaf bold), denote (date `fg2`, keywords italic, title bold), hydra
(`hydra-face-*`: red bold, blue bold italic, amaranth bold underline,
pink bold `double-line`, teal bold `dots`), tldr, neotree, dashboard
(`dashboard-items-face` `fg0`, heading bold, banner `fg1`), csv-mode
(`csv-separator-face` `fg2`), web-mode / nxml / css basics, sh-script
(`sh-heredoc` `fg1`, `sh-quoted-exec` `fg0` italic), ess (follows
font-lock; `ess-*` constant/number faces italic), ein / code-cells (cell
headers bold underline).

When a face is not listed above, decide by analogy with the closest listed
face. Prefer `:inherit` of a theme face over repeating a spec when the face
truly means the same thing (e.g. `consult-preview-match` inherits
`isearch`), but never inherit a face from a package that might not be
loaded.

## Customization

Keep it small:

- `eink-themes-toggle`: command that switches between `eink-light` and
  `eink-dark` (disabling the other first; loads `eink-light` if neither is
  active).
- `eink-themes-get-color NAME &optional VARIANT`: return the palette color
  for symbol NAME (e.g. `'fg2`) of the current eink theme, or of VARIANT
  (`light` / `dark`). For use in user config.
- `eink-themes-after-load-theme-hook`: run after either eink theme loads.

No bold/italic toggles, no palette overrides, no presets. Users who want to
change a face use `custom-theme-set-faces` or `custom-set-faces` as usual.

## Code layout

```
eink-themes.el         ;; palettes, face table, custom variables,
                       ;; eink-themes-theme macro/function, commands,
                       ;; autoload that adds this directory to
                       ;; custom-theme-load-path
eink-light-theme.el    ;; (deftheme eink-light ... :background-mode 'light
                       ;;   :kind 'color-scheme :family 'eink)
                       ;; (eink-themes-theme 'eink-light 'light)
                       ;; (provide-theme 'eink-light)
eink-dark-theme.el     ;; same for dark
tests/eink-themes-test.el
Makefile               ;; make compile, make test, make lint
README.md
DESIGN.md
LICENSE                ;; MIT
```

Implementation shape: palettes are two alists `eink-themes-light-palette`
and `eink-themes-dark-palette`. The face table is one backquoted list of
`(FACE ((t SPEC...)))` entries in which palette names appear as unquoted
symbols (`,fg0`), evaluated inside a `let` that binds every palette name
from the chosen palette. The same applies to the custom-variables list
(`ansi-color-names-vector`, `hl-todo-keyword-faces`,
`pdf-view-midnight-colors`, `flymake-*-bitmap` if useful,
`xterm-color-names(-bright)`, `ibuffer-*` faces vars if colored).
`eink-themes-theme` calls `custom-theme-set-faces` and
`custom-theme-set-variables` with the result. Use `((t ...))` display specs
only; no `class`/`min-colors` branches.

Package header: `Package-Requires: ((emacs "30.1"))` (needed for the
`double-line`, `dots`, `dashes` underline styles). Lexical binding,
`checkdoc` clean, byte-compiles without warnings. Follow the conventions in
the elisp-package-dev guidelines: plain-English names, terse docstrings.

## Tests

`tests/eink-themes-test.el`, ERT, run with `make test`
(`emacs -Q --batch -L . -l tests/eink-themes-test.el -f ert-run-tests-batch-and-exit`):

- both themes load and disable without errors; `eink-themes-toggle` switches
  between them.
- **gray check**: walk every face spec and custom variable value that the
  theme registers (`(get THEME 'theme-settings)`), collect every string that
  is a color (`#...` or a color name), and assert each is `#RRGGBB` with
  `R == G == B` and channel a multiple of `0x11`.
- `default` fg/bg are black on white for light and swapped for dark.
- the source files contain no `#xxxxxx` hex literal outside the palette
  definitions.
- **leak test**: require a list of built-in libraries (everything listed in
  the built-in packages above that `require`s cleanly in batch), enable each
  theme, then for every face in `(face-list)` that the theme does not set,
  scan its defface spec (`face-default-spec`, all display branches) for
  color strings and flag every one that is not gray. A theme spec replaces
  the defface spec entirely (see `face-spec-recalc`), so faces the theme
  sets are covered by the gray check, and faces it leaves alone leak exactly
  the colors in their defface spec. Report all offenders at once. Faces
  whose defface spec uses only `:inherit` are fine. When the environment variable
  `EINK_THEMES_EXTRA_LOAD_PATH` is set (colon-separated directories, e.g.
  `~/.config/emacs/straight/build/*`), also add those to `load-path`,
  require the third-party packages listed above that are present, and run
  the same check. `make test-extra` sets it to the straight build dirs of
  `~/.config/emacs`.
  Batch mode runs on a terminal frame, so check spec values, not
  `face-attribute` results.
- the leak test must pass with zero offenders for built-in libraries and
  for every third-party package present under the straight build dirs.
