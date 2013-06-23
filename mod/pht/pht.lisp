(restas:define-module #:pht
    (:use #:closer-mop #:cl #:iter #:alexandria #:anaphora #:postmodern #:lib)
  (:shadowing-import-from :closer-mop
                          :defclass
                          :defmethod
                          :standard-class
                          :ensure-generic-function
                          :defgeneric
                          :standard-generic-function
                          :class-name)
  (:export :upload))

(in-package #:pht)

(define-automat pic "Автомат картинки"
  ((id             serial)
   (pictype        varchar)
   (uploadfilename varchar)
   (pathnamefile   varchar)
   (namefile       varchar)
   (timestamp      timestamp)
   (user_id        integer))
  ((:uploaded     :deleted      :delpic)))

(defun generate-filename ()
  (symbol-name (gensym "FILE-")))


(defun upload (input-pathname input-filename input-format)
  (awhen (probe-file input-pathname)
    (let* ((output-filename (generate-filename))
           (outfilepath (namestring (ylg:path (concatenate 'string "pic/" output-filename)))))
      (with-open-file (input-stream (namestring input-pathname) :element-type '(unsigned-byte 8) :direction :input)
        (with-open-file (output-stream outfilepath              :element-type '(unsigned-byte 8) :direction :output :if-does-not-exist :create)
          (let ((buf (make-array 4096 :element-type (stream-element-type input-stream))))
            (loop for pos = (read-sequence buf input-stream)
               while (plusp pos)
               do (write-sequence buf output-stream :end pos)))))
      (make-pic :pictype input-format
                :uploadfilename input-filename
                :pathnamefile outfilepath
                :namefile output-filename
                :timestamp (get-universal-time)
                :user_id (usr::id usr:*current-user*)))))
