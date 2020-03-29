(defsystem "engels"
  :version "0.1.0"
  :author "Nikolai Matiushev"
  :license "MIT"
  :defsystem-depends-on (:lassie)
  :depends-on ("lass" "lassie")
  :components ((:module "src"
                :components
                ((:file "main")
                 (:lassie-file "engels" :output "../css/engels.css")))
               (:module "css"
                :depends-on ("src")
                :components
                ((:static-file "engels.css")))
               (:static-file "index.html"))
  
  :description "LASS counterpart of Marx - classless CSS framework")
