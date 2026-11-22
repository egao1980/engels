;;;; engels public API (H4h-0b-2). SKELETON: the bodies land with the PR
;;;; after css-backend-lass 0.1.0 is published.

(defpackage #:engels
  (:use #:cl)
  (:export #:stylesheet #:css-string #:css-octets))

(in-package #:engels)

(defun stylesheet ()
  "The engels theme as a css-protocol stylesheet (light + dark)."
  (error "engels 0.2.0 skeleton: STYLESHEET lands in H4h-0b-2"))

(defun css-string (&key pretty)
  "The compiled theme as CSS text, minified unless PRETTY."
  (declare (ignore pretty))
  (error "engels 0.2.0 skeleton: CSS-STRING lands in H4h-0b-2"))

(defun css-octets ()
  "The compiled theme as UTF-8 octets (canvas-protocol's default asset)."
  (error "engels 0.2.0 skeleton: CSS-OCTETS lands in H4h-0b-2"))
