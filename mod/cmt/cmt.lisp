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
   (votes       :votes))
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

;; Tests
