;;;; engels: Marx's classless stylesheet as LASS, compiled through
;;;; css-backend-lass into the css-protocol model.

(defpackage #:engels
  (:use #:cl)
  (:local-nicknames (#:css #:css-protocol))
  (:export
   ;; palettes and the theme (src/variables.lisp)
   #:*light-palette*
   #:*dark-palette*
   #:palette-colours
   #:theme
   ;; the API (src/engels.lisp)
   #:stylesheet
   #:css
   #:css-octets
   #:source-pathname))
