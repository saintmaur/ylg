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
  :components   (
                 (:file "defmodule")
                 ;; (:static-file "templates.htm")
                 ;; (:file "orgmode")
                 ;; (:file "comment")
                 ;; (:file "sape")
                 ;; (:file "render")
                 ;; (:file "routes")
                 ;; (:file "init")
                 ;; (:static-file "daemon.conf")
                 ;; (:static-file "daemon.lisp")
                 ;; (:static-file "daemon.sh")
                 ))
