;;;; (:engels-theme) -- a LASS special block that compiles to the css-protocol
;;;; theme of src/variables.lisp, so src/engels.lass (and the :lass-stylesheet
;;;; component that builds css/engels.css from it) carries the light / dark
;;;; custom properties. The theme stylesheet (style rules and one @media rule,
;;;; see css-protocol's CSS-THEME-STYLESHEET) is turned back into LASS source
;;;; forms and compiled by LASS like any other form, so the walk into the
;;;; model is css-backend-lass's own. The tests check that the result is
;;;; byte-identical to (css-theme-stylesheet (engels:theme)).

(in-package #:engels)

(defun %selector-list-text (selectors)
  (format nil "~{~a~^,~}"
          (mapcar (lambda (s) (css:selector-text s :pretty nil)) selectors)))

(defun %rule-form (rule)
  "A LASS block form for the css-protocol style RULE."
  (list* (%selector-list-text (css:rule-selectors rule))
         (loop for d in (css:rule-declarations rule)
               collect (intern (string-upcase (css:declaration-property d)) '#:keyword)
               collect (if (css:declaration-important-p d)
                           (format nil "~a !important" (css:declaration-value d))
                           (css:declaration-value d)))))

(defun %theme-forms (sheet)
  "LASS source forms for the theme stylesheet SHEET."
  (loop for node in (css:stylesheet-rules sheet)
        collect (etypecase node
                  (css:rule (%rule-form node))
                  (css:media-rule
                   (list* :media (css:media-rule-query node)
                          (mapcar #'%rule-form (css:at-rule-rules node)))))))

(lass:define-special-block engels-theme ()
  (apply #'lass:compile-sheet (%theme-forms (css:css-theme-stylesheet (theme)))))
