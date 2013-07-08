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
  ((id          serial)
   (entity      varchar)     ;; may be other comment entity
   (entity-id   integer)
   (timestamp   bigint)
   (author      integer)
   (text        text))
  (:public :hidden)
  ((:public  :hidden    :hide-comment)
   (:hidden  :public    :unhide-comment)))


;; (defun build_trees (entity entity-id)
;;   (let ((roots (find-comment #'(lambda (x)
;; 				 (and (equal (entity (car x)) entity)
;; 				      (equal (entity-id (car x)) entity-id))))))
;;     (flet ((tmp (target)
;; 	     ...))
;;       (loop :for root :in roots :collect
;; 	 (tmp root)

;; (make-comment :author 6 :text "комментарий look-а" :entity 'ily::look :entity-id 1 :timestamp (get-universal-time))

;; (make-comment :author 6 :text "комментарий комментария look-а" :entity 'cmt::comment :entity-id 1 :timestamp (get-universal-time))

;; (make-comment :author 6 :text "комментарий комментария комментария look-а" :entity 'cmt::comment :entity-id 2 :timestamp (get-universal-time))

;; (make-comment :author 6 :text "еще один комментарий комментария look-а" :entity 'cmt::comment :entity-id 1 :timestamp (get-universal-time))

;; (make-comment :author 6 :text "еще один комментарий look-а" :entity 'ily::look :entity-id 1 :timestamp (get-universal-time))

(defun get-roots (entity entity-id)
  (find-comment :entity entity :entity-id entity-id))

;; (get-roots 'ily::look 1)
;; (get-roots 'cmt::comment 1)
;; (get-roots 'cmt::comment 2)
;; (get-roots 'cmt::comment 3)

(defun make-tree (root)
  (let ((childs (get-roots (type-of root) (cmt::id root))))
    (list :parent root
          :childs (unless (null childs)
                    (loop :for child :in childs :collect
                       (make-tree child))))))

;; (make-tree (cons (ily::get-look 1) 1))
;; (make-tree (first (get-comment 1)))
;; (make-tree (cons (get-comment 2) 2))
;; (make-tree (cons (get-comment 3) 3))

(defun find-all-comments (entity entity-id)
  (loop :for root :in (get-roots entity entity-id) :collect
     (make-tree root)))

(defun traverse-tree (comments-list root &optional (level 0))
  (let ((id (id (getf root :parent))))
    (setf comments-list
	  (append comments-list
		  (list (list
                 :id id
                 :author (usr::email (first (usr::get-usr (author (getf root :parent)))))
                 :text (text (getf root :parent))
                 :timestamp (timestamp (getf root :parent))
                 :entityId (entity-id (getf root :parent))
                 :entity (entity (getf root :parent))
                 :voting (append (list :id id :entity "comment" :pack "cmt" :vote 1
                                       :voted (vot::check-if-voted
                                               :author (author (getf root :parent))
                                               :entity 'comment
                                               :entity-id id))
                                 (vot::vote-summary 'comment id))
                 :level level))))
    ;;  (format t "~%level: ~A: ~A"         level          (bprint (text (car (getf root :parent)))))
    (unless (null (getf root :childs))
      (incf level)
      (loop :for child :in (getf root :childs) :do
         (setf comments-list
               (traverse-tree comments-list child level))))
    comments-list))


(defun entity-comments (entity entity-id)
  (let ((comments-list))
    (loop :for root :in (find-all-comments entity entity-id) :do
       (setf comments-list
             (traverse-tree comments-list root)))
    comments-list))

(defun get-comment-data (id)
  (let ((comment (first (get-comment id))))
    (if comment
        (list
         :id id
         :text (text comment)
         :author (author comment)
         :timestamp (timestamp comment)
         :entity (string-upcase (entity comment))
         :entity-id (entity-id comment))
        nil)))
