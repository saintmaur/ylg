(asdf:defsystem #:ylg
  :version      "0.0.1"
  :author       "rigidus <i.am.rigidus@gmail.com>"
  :licence      "GPLv3"
  :description  "ylg project"
  :depends-on   (#:closer-mop
                 #:cl-ppcre
                 #:restas-directory-publisher
                 #:closure-template
                 #:cl-json
                 #:postmodern)
  :serial       t
  :components   ((:file "ylg")
                 (:static-file "tpl/tpl.htm")
                 (:file "render")
                 (:file "routes")
                 (:module "lib"
                          :serial t
                          :pathname "lib"
                          :components ((:file "entity")
                                       (:file "datetime")))
                 (:module "usr"
                          :serial t
                          :pathname "mod/usr"
                          :components ((:file "usr")))
                 (:module "ily"
                          :serial t
                          :pathname "mod/ily"
                          :components ((:file "ily")
                                       (:static-file "tpl.htm")
                                       (:file "routes")
                                       ))
                 (:file "init")))
