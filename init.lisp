(in-package #:ylg)

;; start
(restas:start '#:ylg :port 9321)
(restas:debug-mode-on)
;; (restas:debug-mode-off)
(setf hunchentoot:*catch-errors-p* t)
