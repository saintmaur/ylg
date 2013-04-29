(restas:define-module #:crn
    (:use #:closer-mop #:cl #:iter #:alexandria #:anaphora #:postmodern #:lib)
  (:shadowing-import-from :closer-mop
                          :defclass
                          :defmethod
                          :standard-class
                          :ensure-generic-function
                          :defgeneric
                          :standard-generic-function
                          :class-name))

(in-package #:crn)

;; Model

(defun tst ()
  (format t "test")
  (force-output t))

(defun sch-task (func ts)
  "cоздание отложенного задания"
  (let ((tobj (make-timer func)))
    (schedule-timer tobj ts)
    tobj))

(defun mod-task (tobj func ts)
  "редактирование отложенного таска"
  (unless (find tobj (list-all-timers))
		'(return-from mod-task (err-notfound)))
  (sch-task func ts))

(defun del-task (tobj)
  (unschedule-timer tobj)
  "удаление отложенного таска")

(defun err-notfound ()
  (format t "Timer is nor found"))


;; Tests

(defun report-timer-test(name result)
  (format t "Result of ~s is ~s~%" name result))

(defun prep-test-timers()
  (defvar *timers* nil)
    (dotimes (i 10)
      (push (sch-task #'tst (* i 100)) *timers*)))