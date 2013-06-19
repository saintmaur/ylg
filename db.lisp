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

(defun make-clause-list (priv-rel args)
  (let ((clause "") (c 1))
    (loop for i in args
       if (and (keywordp i)
                 (getf args i)
                 (not (keywordp (getf args i))))
         do
         (setf clause (concatenate 'string
                                   clause
                                   (unless (or
                                            (= c 1)
                                            (keywordp (getf args i)))
                                     " and ")
                                   (symbol-name i)
                                   " " (symbol-name priv-rel)
                                   " \'" (getf args i) "\' "))
       end
       do
         (incf c))
    (print clause)))

