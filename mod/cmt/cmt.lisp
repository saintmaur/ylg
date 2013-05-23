(restas:define-module #:cmt
    (:use #:closer-mop #:cl #:iter #:alexandria #:anaphora #:postmodern #:lib)
  (:shadowing-import-from :closer-mop
                          :defclass
                          :defmethod
                          :standard-class
                          :ensure-generic-function
                          :defgeneric
                          :standard-generic-function
                          :class-name)
  ;; (:export :get-look :all-look :find-look :vote)
  )

(in-package #:cmt)

;(closure-template:compile-template :common-lisp-backend (ylg:path "mod/cmt/tpl.htm"))

(define-automat comment "Автомат комментария"
  ((entity      :entity)     ;; may be other comment entity
   (entity-id   :entity-id)
   (timestamp   :timestamp)
   (votes       :votes))
  (:public :hidden)
  ((:public  :hidden    :hide-comment)
   (:hidden  :public    :unhide-comment)))

;; Tests
