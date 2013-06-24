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

(defun make-clause-list (glob-rel rel args)
  (append (list glob-rel) (loop for i in args
                             when (and (symbolp i)
                                       (getf args i)
                                       (not (symbolp (getf args i))))
                             :collect (list rel i (getf args i)))))

(defun query-dao-fun (type query)
  (query-dao 'type
             query))
(defun find-entity (type &rest args)
  (with-connection ylg::*db-spec*
    (apply #'query-dao-fun
           (list*
            (list 'type)
            (list :select :* :from type
                     :where (make-clause-list ':and ':= args))))))
    ;; (query-dao type
    ;;             args)))

(find-entity 'usr::usr :email "seymouur")
