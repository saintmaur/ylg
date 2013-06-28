(restas:define-module #:db-init
    (:use #:closer-mop #:cl #:iter #:alexandria #:anaphora #:postmodern)
  (:shadowing-import-from :closer-mop
                          :defclass
                          :defmethod
                          :standard-class
                          :ensure-generic-function
                          :defgeneric
                          :standard-generic-function
                          :class-name)
  (:export :init-table))

(in-package #:db-init)


(defun make-clause-list (glob-rel rel args)
  (append (list glob-rel)
          (loop
             :for i
             :in args
             :when (and (symbolp i)
                       (getf args i)
                       (not (symbolp (getf args i))))
             :collect (list rel i (getf args i)))))

(make-clause-list ':and ':= (list 'id 1 'name "name"))
