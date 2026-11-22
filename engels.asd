;;;; engels 0.2.1: Marx, the classless CSS framework, as LASS on the cl-stack
;;;; (css-protocol model, css-backend-lass compiler). Slice H4h-0b-2 of
;;;; cl-stack/docs/capabilities/css.md.

(defsystem "engels"
  :version "0.2.1"
  :author "Nikolai Matiushev"
  :license "MIT"
  :description "LASS counterpart of Marx - classless CSS framework, light and dark, on css-protocol"
  :homepage "https://github.com/egao1980/engels"
  :defsystem-depends-on ((:version "css-backend-lass" "0.1.0"))
  :depends-on ((:version "css-protocol" "0.1.0")
               (:version "css-backend-lass" "0.1.0")
               (:version "encoding-protocol" "0.2.0"))
  :components ((:module "src"
                :serial t
                :components
                ((:file "package")
                 (:file "variables")   ; light / dark palettes -> css-protocol theme
                 (:file "theme")       ; the (:engels-theme) LASS special block
                 (:static-file "sanitize.lass") ; sanitize.css 13.0.0 base layer
                 (:static-file "base.lass")
                 (:static-file "typography.lass")
                 (:static-file "forms.lass")
                 (:static-file "buttons.lass")
                 (:static-file "tables.lass")
                 (:static-file "canvas.lass")
                 ;; serial: the includes above make it recompile when they change
                 (:lass-stylesheet "engels" :output "../css/engels.css" :pretty nil)
                 (:file "api")))       ; the API: stylesheet, css, css-octets
               (:module "css"
                :depends-on ("src")
                :components
                ((:static-file "engels.css")))
               (:static-file "index.html"))
  :in-order-to ((test-op (test-op "engels/tests"))))

(defsystem "engels/tests"
  :depends-on ("engels" (:version "html-protocol" "0.1.0") "rove")
  :pathname "tests"
  :serial t
  :components ((:file "package")
               (:file "engels-test"))
  :perform (test-op (o c)
             (unless (symbol-call :rove :run c)
               (error "tests failed for ~A" (component-name c)))))
