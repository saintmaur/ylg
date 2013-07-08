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

(define-automat vote ()
  ((id         serial)
   (user-id    integer)
   (entity     varchar)
   (entity-id  integer)
   (voting     integer)))

(defun check-if-voted (&key author entity entity-id)
  (if (and (first (vot::find-vote :user-id author
                                  :entity entity
                                  :entity-id  entity-id))
           t)
      1  0))

;;TODO доделать!!!!!
(defun vote-summary (entity entity-id)
  (let ((objects (find-vote :entity entity
                            :entity-id  entity-id))
        (sum 0)
        (like 0)
        (dislike 0))
    (mapcar #'(lambda (x)
                (if (equal 1 (vot::voting x))
                    (incf like)
                    (incf dislike))
                (setf sum (+ sum (vot::voting x))))
            objects)
    (list :like like :dislike dislike :sum sum)))

;; (find-vote :entity 'ily::look :entity-id 1)

;; (getf (vote-summary 'ily::look 1) :sum)

;; ;; (let ((entity ...)
;; ;;       (entitu-id ..))
;; ;;   (find-comment #'(lambda (x)
;; ;; 		    (and (equal (entity (car x)) entity)
;; ;; 			 (equal (entity-id (car x)) entity-id)))))
