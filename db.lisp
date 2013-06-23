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


(defmacro init-table-class (fields-list &key (key 'id) (db-spec 'ylg::*db-spec*) table)
  (let ((class-name (intern (string-upcase table)))
        (pkey (intern (string-upcase key)))
        (func (intern (string-upcase (concatenate 'string "init-table")))))
    `(progn
       (defclass ,class-name ()
         ,fields-list
         (:metaclass dao-class)
         (:key ,pkey))
       (defun ,func ()
         (with-connection ,db-spec
           (unless (table-exists-p ,table)
             (execute (dao-table-definition ',class-name))))))))

(defun make-clause-list (args)
  (loop for i in args
     when (and (keywordp i)
               (getf args i)
               (not (keywordp (getf args i))))
     :collect `(,i ,(getf args i)))

  )
