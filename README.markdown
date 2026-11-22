# Engels - LASS counterpart of Marx - classless CSS framework

[Marx](https://github.com/mblode/marx), the classless CSS framework, written in [LASS](https://codeberg.org/shinmera/LASS) and compiled on the cl-stack: [css-backend-lass](https://github.com/egao1980/css-backend-lass) turns `src/*.lass` into the [css-protocol](https://github.com/egao1980/css-protocol) stylesheet model, and the model is serialized to `css/engels.css`. It styles semantic elements only (no classes), in light and dark.

**Status:** 0.2.1 (slice H4h-0b-2 of [cl-stack/docs/capabilities/css.md](https://github.com/egao1980/cl-stack/blob/main/docs/capabilities/css.md)). It is canvas-protocol's default theme (H4h-0b-3).

## Usage

```lisp
(asdf:load-system "engels")

(engels:stylesheet)          ; => a css-protocol:stylesheet (cached)
(engels:css)                 ; => pretty CSS text
(engels:css :minify t)       ; => minified, byte-identical to css/engels.css
(engels:css-octets)          ; => the minified text as UTF-8 octets
```

The model can be transformed like any css-protocol stylesheet, for example pruned to what one page uses and scoped to a frozen canvas:

```lisp
(css-protocol:scope-stylesheet
 (css-protocol:used-rules (engels:stylesheet) page-tree)
 "[data-canvas]")
```

Or used without Lisp: link `css/engels.css` (committed; rebuilt by ASDF when a source changes).

## Base layer

Marx is built on [sanitize.css](https://github.com/csstools/sanitize.css), and so is engels: `src/sanitize.lass` is sanitize.css 13.0.0 (`sanitize.css` and `forms.css`) translated rule for rule, compiled after the theme and before the Marx partials. It gives border-box sizing, collapsed table borders and form controls that inherit the font. Its selectors are all `:where(...)`, so the Marx rules win. Differences from upstream: colours come from the theme (`dialog`, control and fieldset borders), and the `select` arrow rules are left out because they use `url()`. 0.2.1 also makes tables full width.

## Light and dark

Every colour is a custom property, `--engels-*`, set by a css-protocol theme (`engels:theme`, from `engels:*light-palette*` and `engels:*dark-palette*` in `src/variables.lisp`):

- `:root` holds the light colours and `color-scheme: light dark`;
- `@media (prefers-color-scheme: dark)` switches to the dark ones;
- `data-theme="dark"` or `data-theme="light"` on `<html>` forces a mode, whatever the OS says.

The light palette is Marx's. Its derived colours (hover, active, focus) come from css-backend-lass's colour functions with Marx's amounts, so they are the values engels 0.1.0 printed (`#0069D9`, `#0062CC`, `#005CBF`, `#80BDFF`, `#EA1C0D`). The dark palette lightens where the light one darkens.

## Beyond Marx

`src/canvas.lass` covers canvas-protocol's closed `data-*` vocabulary (`data-layout` stack / row / grid, `data-gap`, `data-columns`, `data-align`, `data-badge`) and the `aria-*` states its components emit (`aria-invalid`, `aria-sort`, `role="tablist"` / `aria-selected`, `small[role="alert"]`). The output has no `url(` and no `@import`, so a frozen canvas stays offline.

## Building

```lisp
(defsystem "engels"
  :defsystem-depends-on ((:version "css-backend-lass" "0.1.0"))
  :components ((:module "src" :serial t
                :components (... (:lass-stylesheet "engels" :output "../css/engels.css" :pretty nil)))))
```

`src/engels.lass` binds the sizes and the colour names in a `:let*`, writes the theme with the `(:engels-theme)` special block, then `:include`s the partials. Tests: `cl-repo test --system engels` (Rove).

## Author

* Nikolai Matiushev

## License

MIT, see [LICENSE](LICENSE). Engels is a port of Marx, MIT, Copyright (c) Matthew Blode; its notice is in LICENSE, and a reference copy of Marx's CSS is in [docs/marx.css](docs/marx.css).

## Credits

- [Marx](https://github.com/mblode/marx), MIT, Copyright (c) Matthew Blode.
- [sanitize.css](https://github.com/csstools/sanitize.css) 13.0.0 (https://unpkg.com/sanitize.css@13.0.0/), CC0-1.0, Jonathan Neal and Nicolas Gallagher: the base layer in `src/sanitize.lass`.
