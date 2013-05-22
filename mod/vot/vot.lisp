(restas:define-module #:vot
    (:use #:closer-mop #:cl #:iter #:alexandria #:anaphora #:postmodern #:lib)
  (:shadowing-import-from :closer-mop
                          :defclass
                          :defmethod
                          :standard-class
                          :ensure-generic-function
                          :defgeneric
                          :standard-generic-function
                          :class-name)
  (:export :make-vote :get-vote :all-vote :find-vote :entity-id :entity))

(in-package #:vot)

;; (closure-template:compile-template :common-lisp-backend (ylg:path "mod/vot/tpl.htm"))

(define-entity vote ()
  ((user-id    :user-id)
   (entity     :entity)
   (entity-id  :entity-id)
   (voting     :voting)))

;; (vote-look 1 'like 3)
;; (votes (get-look 1))
;; (entity-id (get-vote 2))
;; (entity-id (get-vote 2))
