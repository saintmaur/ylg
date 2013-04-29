;(restas:define-module #:crn
;    (:use #:closer-mop #:cl #:iter #:alexandria #:anaphora #:postmodern #:lib)
;  (:shadowing-import-from :closer-mop
;                          :defclass
;                          :defmethod
;                          :standard-class
;                          :ensure-generic-function
;                          :defgeneric
;                          :standard-generic-function
;                          :class-name)
;  (:export :sch-task :mod-task :del-task :list-timers))

;(in-package #:crn)

;; Model

(defun tst ()
  (format t "test~%")
  (force-output t))

(defun tst2 ()
  (format t "test2~%")
  (force-output t))

(defun sch-task (func ts name)
  "Создание таймера"
  (let ((tobj (make-timer func :name name)))
    (schedule-timer tobj ts)
    name))

(defun mod-task (name func ts)
  "Редактирование таймера"
  (let ((timer (get-timer-by-name name)))
    (if (not timer)
	(err-notfound)
	(progn
	  (del-task name)
	  (sch-task func ts name)))))

(defun del-task (name)
  "Удаление таймера"
  (let ((timer (get-timer-by-name name)))
    (if (not timer)
	(err-notfound)
	(unschedule-timer timer))))

(defun get-timer-by-name(name)
  "Поиск таймера по имени"
  (dolist (timer (list-all-timers))
    (when (EQUAL (timer-name timer) name)
      (return-from get-timer-by-name timer)))
  nil)

(defun list-timers ()
  ;TODO prepare timers list
  (list-all-timers))

(defun err-notfound ()
  "Timer is not found")

;; Tests

(defun prep-test-timers()
  (let ((timers nil) (timer nil) (newtime 5))
    (dotimes (i 10)
      (setf timer (sch-task #'tst (* (+ i 5) 100) (gensym)))
      (format t "Timer ~s is created is set for ~s sec~%" timer (+ i 5))
      (push timer timers))
    (format t "===================~%")
    (dolist (timer timers)
      (mod-task timer  #'tst2 (+ 1 newtime))
      (format t "Timer ~s is changed for ~s sec~%" timer (incf newtime)))
    (format t "===================~%")
    (dotimes (i newtime)
      (format t "~d " (+ 1 i))
      (force-output t)
      (when (= i (random (+ newtime 1)))
	(del-task (timer-name (first (list-timers)))))
      (sleep 1))
    (format t "~%")))