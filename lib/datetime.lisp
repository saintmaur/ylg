(in-package #:lib)


(defun decode-date (timestamp)
  (multiple-value-bind (second minute hour date month year)
      (decode-universal-time timestamp)
    (declare (ignore second minute hour))
    (format nil
            "~2,'0d.~2,'0d.~d"
            date
            month
            year)))

(defun parse-date (datestring)
  "Date is YYYY-MM-DD, returns universal time."
  (unless (string-equal date "")
    (apply #'encode-universal-time
           (append '(0 0 0)
                   (nreverse (mapcar #'parse-integer
                                     (ppcre:split "-" date)))))))
