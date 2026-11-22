;;;; The colours: a light palette (Marx's) and a dark one. Each entry is
;;;; (NAME LASS-VALUE-FORM); a form may use css-backend-lass's colour
;;;; functions (darken, lighten, mix, fade-out, ...) and #(name) references
;;;; to earlier entries, like a LASS :let*. PALETTE-COLOURS resolves them in
;;;; order; THEME turns both into a css-protocol custom-property theme, one
;;;; --engels-NAME per entry. The rules in src/*.lass only ever say
;;;; var(--engels-NAME) (bound in src/engels.lass), so the colours change
;;;; with prefers-color-scheme and the data-theme attribute and nothing else.
;;;;
;;;; Both palettes must list the same names in the same order (tested).

(in-package #:engels)

(defparameter *light-palette*
  '(;; surfaces
    (bg "#fff")
    (surface "#fff")                    ; form controls
    (code-bg "#f7f7f9")                 ; Marx's $grey, pre blocks
    ;; text (Marx's material-style alphas)
    (text "rgba(0, 0, 0, 0.8)")
    (secondary "rgba(0, 0, 0, 0.54)")
    (disabled "rgba(0, 0, 0, 0.38)")
    (dividers "rgba(0, 0, 0, 0.12)")
    ;; primary and its states (Marx's darken / mix / fade-out amounts)
    (primary "#007bff")
    (primary-hover (darken #(primary) 0.075))          ; #0069D9
    (primary-active (darken #(primary) 0.1))           ; #0062CC
    (primary-active-border (darken #(primary) 0.125))  ; #005CBF
    (on-primary "#fff")
    (focus-ring (fade-out #(primary) 0.5))
    (input-focus-border (mix #(primary) #(surface)))   ; #80BDFF
    (input-focus-ring (fade-out #(primary) 0.75))
    ;; links
    (link #(primary))
    (link-hover (darken #(primary) 0.1))               ; #0062CC
    ;; states
    (red "#f44336")
    (red-dark (darken #(red) 0.1))                     ; #EA1C0D
    (ok "#1e7e34")
    (warn "#b45309")
    (mark-bg "#ffeb3b")
    (mark-text "rgba(0, 0, 0, 0.8)"))
  "Marx's colours. NAME -> LASS value form, in order.")

(defparameter *dark-palette*
  '((bg "#16181d")
    (surface "#1e2127")
    (code-bg "#262a31")
    (text "rgba(255, 255, 255, 0.87)")
    (secondary "rgba(255, 255, 255, 0.6)")
    (disabled "rgba(255, 255, 255, 0.38)")
    (dividers "rgba(255, 255, 255, 0.16)")
    ;; a lighter primary for contrast on the dark background; its states
    ;; lighten where the light palette darkens
    (primary "#4da3ff")
    (primary-hover (lighten #(primary) 0.075))
    (primary-active (lighten #(primary) 0.1))
    (primary-active-border (lighten #(primary) 0.125))
    (on-primary "#0b1220")
    (focus-ring (fade-out #(primary) 0.5))
    (input-focus-border (mix #(primary) #(surface)))
    (input-focus-ring (fade-out #(primary) 0.75))
    (link #(primary))
    (link-hover (lighten #(primary) 0.1))
    (red "#ff6b5e")
    (red-dark (lighten #(red) 0.1))
    (ok "#4cd07d")
    (warn "#f0b429")
    (mark-bg "#e6c84f")
    (mark-text "#16181d"))
  "The dark counterpart of *LIGHT-PALETTE*: same names, same order.")

(defun palette-colours (palette)
  "PALETTE's colours as an alist (\"engels-NAME\" . css-text), resolved in
order with css-backend-lass's LASS functions, each seeing the earlier ones."
  (let ((lass:*vars* (make-hash-table)))
    (loop for (name form) in palette
          for value = (lass:resolve form)
          do (setf (gethash name lass:*vars*) value)
          collect (cons (format nil "engels-~(~a~)" name) value))))

(defun theme (&key (light *light-palette*) (dark *dark-palette*) (selector ":root"))
  "The engels colours as a css-protocol theme: light on SELECTOR, dark under
prefers-color-scheme: dark, both forced with data-theme=\"light\" / \"dark\"."
  (css:make-css-theme :light (palette-colours light)
                      :dark (palette-colours dark)
                      :selector selector
                      :toggle-attribute "data-theme"))
