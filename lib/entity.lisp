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
  (let ( (inc            (intern (concatenate 'string "INC-"    (symbol-name name) "-ID")))
        (incf-inc       (intern (concatenate 'string "INCF-"    (symbol-name name) "-ID")))
         (init-inc       (intern (concatenate 'string "INIT-"    (symbol-name name) "-ID")))
         (container      (intern (concatenate 'string "*"        (symbol-name name) "*")))
         (count-entity   (intern (concatenate 'string "COUNT-"   (symbol-name name))))
         (make-entity    (intern (concatenate 'string "MAKE-"    (symbol-name name))))
         (show-entity    (intern (concatenate 'string "SHOW-"    (symbol-name name))))
         (del-entity     (intern (concatenate 'string "DEL-"     (symbol-name name))))
         (all-entity     (intern (concatenate 'string "ALL-"     (symbol-name name))))
         (get-entity     (intern (concatenate 'string "GET-"     (symbol-name name))))
         (find-entity    (intern (concatenate 'string "FIND-"    (symbol-name name))))
         (table          (intern (symbol-name name) )))
    `(let ((,inc 0))
       ;; incrementor
       (defun ,incf-inc ()
         (incf ,inc))
       ;; incrementor init
       (defun ,init-inc (init-value)
         (setf ,inc init-value))
       ;; container
       (defparameter ,container (make-hash-table :test #'equal))
       ;; container counter
       (defun ,count-entity ()
         (hash-table-count ,container))
       ;; class
       (defclass ,name ()
         ,(mapcar #'(lambda (x)
                      (list
                       (car x)
                       :col-type (cadr x)
                       :initarg (intern (symbol-name (car x)) )
                       :accessor (car x)
                       ))
                  (car tail))
         (:metaclass dao-class)
         (:table-name ,table)
         (:key id))
       ;; ,(let ((table-name (intern (string-upcase (symbol-name name)))))
       ;;       (with-connection ylg::*db-spec*
       ;;         (unless (table-exists-p table-name)
       ;;           (execute (dao-table-definition table-name)))))
       ;; make-entity
       (defun ,(intern "MAKE-TABLE") ()
         (with-connection ylg::*db-spec*
           (unless (table-exists-p ',table)
             (execute (dao-table-definition ',table)))))

       (defun ,make-entity (&rest initargs)
         (with-connection ylg::*db-spec*
          (apply #'make-dao
                  (list* ',table initargs))))
;;          (let ((id (,incf-inc)))
            ;; todo: duplicate by id
            ;; todo: duplicate by fields
            ;; (values
            ;;  (setf (gethash id ,container)
            ;;        (apply #'make-instance
            ;;               (list* ',name initargs)))
            ;;  id)))

       (defun ,del-entity (id)
         (with-connection ylg::*db-spec*
           (query-dao ',table (:delete :from ',table :where (:= :id id)))))
       ;;(remhash id ,container))
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
       ;; find-entity - поиск айдишника по объекту
       ;; (defmethod ,find-entity ((obj ,name))
       ;;   (do-hash (,container)
       ;;     (when (equal v obj)
       ;;       (return k))))
       (defun ,show-entity (filter)
         (let ((fields (table-description ',table)))
           (format nil
                   (view::render-elem :args (fields)))))

       (defun ,find-entity (&rest args)
         (with-connection ylg::*db-spec*
           (query-dao
            ',table
            (sql-compile
             (list :select :* :from ',table
                   :where (db-init::make-clause-list ':and ':= args))))))
       )))


(defmacro define-automat (name desc &rest tail)
  (let ((package (symbol-package name)))
  `(progn
     (define-entity ,name ,desc ,(car tail))
     ;create the table if doesn't exist
     (,(intern "MAKE-TABLE"))
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
                (,(intern "TRANS" package) obj (,(intern "STATE" package) obj) new-state event)))))))
