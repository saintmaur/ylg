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
           :define-action
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
  (let ((inc            (intern (concatenate 'string "INC-"     (symbol-name name) "-ID")))
        (incf-inc       (intern (concatenate 'string "INCF-"    (symbol-name name) "-ID")))
        (init-inc       (intern (concatenate 'string "INIT-"    (symbol-name name) "-ID")))
        (container      (intern (concatenate 'string "*"        (symbol-name name) "*")))
        (count-entity   (intern (concatenate 'string "COUNT-"   (symbol-name name))))
        (make-entity    (intern (concatenate 'string "MAKE-"    (symbol-name name))))
        (del-entity     (intern (concatenate 'string "DEL-"     (symbol-name name))))
        (all-entity     (intern (concatenate 'string "ALL-"     (symbol-name name))))
        (get-entity     (intern (concatenate 'string "GET-"     (symbol-name name))))
        (find-entity    (intern (concatenate 'string "FIND-"    (symbol-name name)))))
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
                       ;; :col-type (cadr x)
                       :initarg (intern (symbol-name (car x)) :keyword)
                       :initform (caddr x)
                       :accessor (car x)
                       ))
                  (car tail)))
       ;; make-entity
       (defun ,make-entity (&rest initargs)
         (let ((id (,incf-inc)))
           ;; todo: duplicate by id
           ;; todo: duplicate by fields
           (values
            (setf (gethash id ,container)
                  (apply #'make-instance
                         (list* ',name initargs)))
            id)))
       (defun ,del-entity (id)
         (remhash id ,container))
       (defun ,all-entity ()
         (do-hash-collect (,container)
           (cons v k)))
       ;; get-entity (by id, typesafe, not-present safe)
       (defun ,get-entity (var)
         (when (typep var 'integer)
           (multiple-value-bind (hash-val present-p)
               (gethash var ,container)
             (unless present-p
               (err 'not-present))
             (setf var hash-val)))
         (unless (typep var ',name)
           (err 'param-user-type-error))
         var)
       ;; find-entity - поиск айдишника по объекту
       (defmethod ,find-entity ((obj ,name))
         (do-hash (,container)
           (when (equal v obj)
             (return k))))
       ;; find-entity - поиск объекта по содержимому его полей
       (defmethod ,find-entity ((func function))
         (let ((rs))
           (mapcar #'(lambda (x)
                       (if (funcall func x)
                           (push x rs)))
                   (,all-entity))
           rs))
       )))


(defmacro define-action (name params &body body)
  `(defun ,name ()
     (let ,(loop :for param :in params :collect
              `(,param (getform ,(intern (symbol-name param) :keyword))))
       ,@body)))


(defmacro define-automat (name desc &rest tail)
  `(progn
     (define-entity ,name ,desc
       ,(list* '(state :state) (car tail)))
     ,(let ((all-states (cadr tail)))
           `(progn
              ,@(loop :for (from-state to-state event) :in (caddr tail) :collect
                   (if (or (null (find from-state all-states))
                           (null (find to-state all-states)))
                       (err (format nil "unknown state: ~A -> ~A" from-state to-state))
                       `(defmethod trans ((obj ,name)
                                          (from-state (eql ,from-state)) (to-state (eql ,to-state))
                                          (event (eql ,event)))
                          (prog1 (,(intern (symbol-name event) *package*))
                            (setf (state obj) ,to-state)))))
              (defmethod takt ((obj ,name) new-state event)
                (trans obj (state obj) new-state event))))))
