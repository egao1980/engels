;;;; The API. css/engels.css is what the :lass-stylesheet component writes
;;;; at COMPILE-OP; these functions compile the same source at run time (once,
;;;; then cached), so (css :minify t) and (css-octets) are its exact text and
;;;; bytes.

(in-package #:engels)

(defun source-pathname ()
  "The LASS entry point, src/engels.lass."
  (asdf:system-relative-pathname "engels" "src/engels.lass"))

(defvar *stylesheet* nil
  "The compiled stylesheet, built on the first STYLESHEET call.")

(defun stylesheet ()
  "The engels theme as a css-protocol stylesheet: the light / dark custom
properties (THEME), then Marx's rules and the canvas vocabulary. The model is
shared: transform it (css-protocol transforms never mutate), do not modify it."
  (or *stylesheet*
      (setf *stylesheet* (css-backend-lass:compile-lass-file (source-pathname)))))

(defun css (&key minify)
  "The compiled theme as CSS text: pretty, or minified (= css/engels.css)
when MINIFY."
  (css:write-stylesheet (stylesheet) :pretty (not minify)))

(defun css-octets ()
  "The minified theme as UTF-8 octets: canvas-protocol's canvas.css asset."
  (encoding-protocol:encode (css :minify t) :encoding :utf-8))
