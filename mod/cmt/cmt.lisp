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




;; (defun build_trees (entity entity-id)
;;   (let ((roots (find-comment #'(lambda (x)
;; 				 (and (equal (entity (car x)) entity)
;; 				      (equal (entity-id (car x)) entity-id))))))
;;     (flet ((tmp (target)
;; 	     ...))
;;       (loop :for root :in roots :collect
;; 	 (tmp root)


;;   (test 'ily::look 1)

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
		(push (list :id id :author author :text text :timestamp ts :entity-id entity-id :voting (vot::vote-summary 'cmt::comment id) :children nil) entity-comments-list))
	    objects)
    entity-comments-list))

;; Tests

(make-comment :author-id 1 :text "комментарий look-а" :entity 'ily::look :entity-id 1 :timestamp (get-universal-time))

(make-comment :author-id 1 :text "комментарий комментария look-а" :entity 'cmt::comment :entity-id 1 :timestamp (get-universal-time))

(make-comment :author-id 1 :text "комментарий комментария комментария look-а" :entity 'cmt::comment :entity-id 2 :timestamp (get-universal-time))

(make-comment :author-id 1 :text "еще один комментарий комментария look-а" :entity 'cmt::comment :entity-id 1 :timestamp (get-universal-time))

(make-comment :author-id 1 :text "еще один комментарий look-а" :entity 'ily::look :entity-id 1 :timestamp (get-universal-time))



(sort (entity-comments 'ily::look 1) #'> :key #'(lambda(x) (getf x :timestamp)))


(defun get-roots (entity entity-id)
  (find-comment #'(lambda (x)
                    (and (equal (entity (car x)) entity)
                         (equal (entity-id (car x)) entity-id)))))

(get-roots 'ily::look 1)
(get-roots 'cmt::comment 1)
(get-roots 'cmt::comment 2)
(get-roots 'cmt::comment 3)

(defun make-tree (root)
  (let ((childs (get-roots (type-of (car root)) (cdr root))))
    (list :parent root
          :childs (unless (null childs)
                    (loop :for child :in childs :collect
                       (make-tree child))))))

(make-tree (cons (ily::get-look 1) 1))
(make-tree (cons (get-comment 1) 1))
(make-tree (cons (get-comment 2) 2))
(make-tree (cons (get-comment 3) 3))

(defun find-all-comments (entity entity-id)
  (loop :for root :in (get-roots entity entity-id) :collect
     (make-tree root)))

(find-all-comments 'ily::look 1)

(defun traverse-tree (root &optional (level 0))
  (format t "~%level: ~A: ~A"
          level
          (bprint (text (car (getf root :parent)))))
  (unless (null (getf root :childs))
    (incf level)
    (loop :for child :in (getf root :childs) :do
       (traverse-tree child level))))

;; смотри на вывод в консоли
(loop :for root :in (find-all-comments 'ily::look 1) :do
   (traverse-tree root))
