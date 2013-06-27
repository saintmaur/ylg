(restas:define-module #:view
    (:use #:closer-mop #:cl #:iter #:alexandria #:anaphora #:postmodern)
  (:shadowing-import-from :closer-mop
                          :defclass
                          :defmethod
                          :standard-class
                          :ensure-generic-function
                          :defgeneric
                          :standard-generic-function
                          :class-name))
(in-package #:view)

(defun render-elem (&key (paired nil) (tag "") (text "") (attrs ()))
  (let ((*injected-data* '(:attrs attrs)))
      (if (null paired)
          (tpl:single (list :attrs attrs))
          (if (null text)
              ""
              (tpl:double (list :tag tag :text text :attrs attrs))))))

;; (render-elem :attrs (list :name "name"))

;; (render-elem :paired t :tag "select" :attrs (list :name "category")
;;              :text (let ((text ""))
;;                      (loop for i in (list '(:val 1 :text "fsfd") '(:val 2 :text "dddddfsfd") '(:val 3 :text "dfvfsfd"))
;;                         do (setf text (concatenate 'string text
;;                                                   (render-elem :paired t :tag "option" :attrs (list :value (getf i :val)) :text (getf i :text)))))
;;                      text))
