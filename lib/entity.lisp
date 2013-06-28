(restas:define-module #:lib
    (:use #:closer-mop #:cl #:iter #:alexandria #:anaphora #:postmodern)
  (:shadowing-import-from :closer-mop
                          :defclass
                          :defmethod
                          :standard-class
                          :ensure-generic-function
                          :defgeneric
                          :standard-generic-function
                          :class-name)
  (:export :bprint
           :err
           :do-hash
           :do-hash-collect
           :append-link
           :replace-all
           :define-entity
           :define-automat))

(in-package #:lib)

;; macro-utils

(defmacro bprint (var)
  `(subseq (with-output-to-string (*standard-output*)  (pprint ,var)) 1))

(defmacro err (var)
  `(error (format nil "ERR:[~A]" (bprint ,var))))

(defmacro do-hash ((ht &optional (v 'v) (k 'k)) &body body)
  `(loop :for ,v :being :the :hash-values :in ,ht :using (hash-key ,k) :do
      ,@body))

(defmacro do-hash-collect ((ht &optional (v 'v) (k 'k)) &body body)
  `(loop :for ,v :being :the :hash-values :in ,ht :using (hash-key ,k) :collect
      ,@body))

(defmacro append-link (lst elt)
  `(setf ,lst (remove-duplicates (append ,lst (list ,elt)))))

(defun replace-all (string part replacement &key (test #'char=))
  "Returns a new string in which all the occurences of the part
 is replaced with replacement."
  (with-output-to-string (out)
    (loop with part-length = (length part)
       for old-pos = 0 then (+ pos part-length)
       for pos = (search part string
                         :start2 old-pos
                         :test test)
       do (write-string string out
                        :start old-pos
                        :end (or pos (length string)))
       when pos do (write-string replacement out)
       while pos)))


;; define-entity

(defmacro define-entity (name desc &rest tail)
  (let ((make-entity-table  (intern (concatenate 'string "MAKE-"  (symbol-name name) "-TABLE")))
        (make-entity        (intern (concatenate 'string "MAKE-"  (symbol-name name))))
        (show-entity        (intern (concatenate 'string "SHOW-"  (symbol-name name))))
        (del-entity         (intern (concatenate 'string "DEL-"   (symbol-name name))))
        (all-entity         (intern (concatenate 'string "ALL-"   (symbol-name name))))
        (get-entity         (intern (concatenate 'string "GET-"   (symbol-name name))))
        (find-entity        (intern (concatenate 'string "FIND-"  (symbol-name name))))
        (table              (intern (symbol-name name))))
    `(progn
       ;; class
       (defclass ,name ()
         ,(mapcar #'(lambda (x)
                      (list
                       (car x)
                       :col-type (cadr x)
                       :initarg  (intern (symbol-name (car x)))
                       :accessor (car x)))
                  (car tail))
         (:metaclass dao-class)
         (:table-name ,table)
         (:key id))
       ;; make-entity-table
       (defun ,make-entity-table ()
         (with-connection ylg::*db-spec*
           (unless (table-exists-p ',table)
             (execute (dao-table-definition ',table)))))
       ;; make-entity
       (defun ,make-entity (&rest initargs)
         (with-connection ylg::*db-spec*
           (apply #'make-dao (list* ',table initargs))))
       ;; del-entity
       (defun ,del-entity (id)
         (with-connection ylg::*db-spec*
           (query-dao ',table (:delete :from ',table :where (:= :id id)))))
       ;; all-entity
       (defun ,all-entity ()
         (with-connection ylg::*db-spec*
           (select-dao ',table)))
       ;; get-entity (by id, typesafe, not-present safe)
       (defun ,get-entity (var)
         (let ((rec))
           (when (typep var 'integer)
             (with-connection ylg::*db-spec*
               (setf rec (select-dao ',table (:= :id var)))))
           (unless (typep var ',name)
             (err 'param-user-type-error))
           rec))
       ;; find-entity
       (defun ,find-entity (&rest args)
         (with-connection ylg::*db-spec*
           (query-dao ',table
                      (sql-compile
                       (list :select :* :from ',table
                             :where (db-init::make-clause-list ':and ':= args))))))
       ;; show-entity
       (defun ,show-entity (&optional ids filter)
         (with-connection ylg::*db-spec*
           (let ((fields (mapcar #'(lambda (x)
                                     (when (not (find (car x) filter))
                                       (car x)))
                                 (table-description ',table))))
             (apply #'format
                    (list*
                     nil
                     (loop for field in fields :collect
                          (let ((func-name (intern (concatenate 'string "SHOW-" (string-upcase field))))
                                (field-sym (intern field :keyword)))
                            (error (type-of (values field-sym)))
                            (list (values func-name) (getf ids (values field-sym)))))))))))))


(defmacro define-automat (name desc &rest tail)
  (let ((package (symbol-package name)))
  `(progn
     (define-entity ,name ,desc ,(car tail))
     (,(intern (concatenate 'string "MAKE-"  (symbol-name name) "-TABLE")))
     ,(let ((all-states (cadr tail)))
           `(progn
              ,@(loop :for (from-state to-state event) :in (caddr tail) :collect
                   (if (or (null (find from-state all-states))
                           (null (find to-state all-states)))
                       (err (format nil "unknown state: ~A -> ~A" from-state to-state))
                       `(defmethod ,(intern "TRANS" package) ((obj ,name)
                                                              (from-state (eql ,from-state))
                                                              (to-state (eql ,to-state))
                                                              (event (eql ,event)))
                          (prog1 (,(intern (symbol-name event) *package*))
                            (setf (,(intern "STATE" package) obj) ,to-state)))))
              (defmethod ,(intern "TAKT" package) ((obj ,name) new-state event)
                (,(intern "TRANS" package) obj (,(intern "STATE" package) obj) new-state event))))
     )))
