(restas:define-module #:ily
    (:use #:closer-mop #:cl #:iter #:alexandria #:anaphora #:postmodern)
  (:shadowing-import-from :closer-mop
                          :defclass
                          :defmethod
                          :standard-class
                          :ensure-generic-function
                          :defgeneric
                          :standard-generic-function
                          :class-name))

(in-package #:ily)

(define-automat look "Автомат look-а"
  ((...fields...))
  (...states...)
  (...transitions))


(define-action ....)


;; Tests

;; ...
