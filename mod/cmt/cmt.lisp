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
   (votes       :votes)
   (author-id   :author-id)
   (text        :text)
   (parent-id   :parent-id))
  (:public :hidden)
  ((:public  :hidden    :hide-comment)
   (:hidden  :public    :unhide-comment)))


(defun vote-comment (comment-id voting &optional (current-user usr:*current-user*))
  (let ((vote (vot:make-vote :entity-id comment-id
                             :entity 'comment
                             :user-id (usr::find-user (usr::get-user current-user))
                             :voting voting))
        (comment (get-comment comment-id)))
    (setf (votes comment)
          (append (votes comment)
                  (list (vot:find-vote vote))))))




(defun build_trees (entity entity-id)
  (let ((roots (find-comment #'(lambda (x)
				 (and (equal (entity (car x)) entity)
				      (equal (entity-id (car x)) entity-id))))))
    (flet ((tmp (target)
	     ...))
      (loop :for root :in roots :collect
	 (tmp root)


  (test 'ily::look 1)

(defun entity-comments (entity entity-id)
  (let ((objects (find-comment #'(lambda (x)
				   (and (equal (entity (car x)) entity)
					(equal (entity-id (car x)) entity-id)))))
	(id 0)
	(author 0)
	(text 0)
	(ts 0)
	(parent-id 0)
	(votes nil)
	(entity-comments-list nil))
    (mapcar #'(lambda (x)
		(setf id (cdr x))
		(setf parent-id (cmt::parent-id (car x)))
		(setf author (cmt::author-id (car x)))
		(setf ts (cmt::timestamp (car x)))
		(setf text (cmt::text (car x)))
		(push (list :id id :author author :text text :timestamp ts :entity-id entity-id :votes votes :children nil) entity-comments-list))
	    objects)
    entity-comments-list))

;; Tests


(make-comment :author-id 1 :text "test" :entity 'ily::look :entity-id 1 :timestamp (get-universal-time))

;; (find-comment #'(lambda (x)
;; 		  (and (equal (entity (car x)) 'ily::look)
;;                                      (equal (entity-id (car x)) 1))))

(sort (entity-comments 'ily::look 1) #'> :key #'(lambda(x) (getf x :timestamp)))

(loop for item in list
     do ())

(process-properties (entity-comments 'ily::look 1) (list :parent-id :timestamp))

