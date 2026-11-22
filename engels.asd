;;;; engels 0.2.0 on the cl-stack (slice H4h-0b-2). SKELETON: needs
;;;; css-backend-lass 0.1.0 (H4h-0b-1) on GHCR before it loads.
;;;; Plan: cl-stack/docs/capabilities/css.md, "engels 0.2.0 on the stack".

(defsystem "engels"
  :version "0.2.0"
  :author "Nikolai Matiushev"
  :license "MIT"
  :description "LASS counterpart of Marx - classless CSS framework, light and dark, on css-protocol"
  :defsystem-depends-on ("css-backend-lass")
  :depends-on ("css-protocol" "css-backend-lass")
  :components ((:module "src"
                :components
                ((:file "package")
                 (:lass-stylesheet "engels" :output "../css/engels.css" :pretty nil)))
               (:module "css"
                :depends-on ("src")
                :components
                ((:static-file "engels.css")))
               (:static-file "index.html"))
  :in-order-to ((test-op (test-op "engels/tests"))))

(defsystem "engels/tests"
  :depends-on ("engels" "rove")
  :pathname "tests"
  :serial t
  :components ((:file "package"))
  :perform (test-op (o c)
             (unless (symbol-call :rove :run c)
               (error "tests failed for ~A" (component-name c)))))
