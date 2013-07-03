(in-package #:ily)

(defun SHOW-FLD-SERIAL (name &optional value)
  (format nil (view::render-elem :paired nil :attrs (list :type "hidden" :name name :value value))))

(defun SHOW-FLD-VARCHAR (name &optional value)
  (format nil (view::render-elem :paired nil :attrs (list :type "text" :name name :value value))))

(defun SHOW-FLD-LIST (name &optional value)
  (if (null value)
      (setf value 1))
  (let ((reasons
         (with-connection ylg::*db-spec*
           (query
            (:select :* :from 'reasons) :plists))))
    (view::render-elem :paired t :tag "select" :attrs (list :name name)
                       :text (let ((text ""))
                               (loop for i in reasons
                                  do (setf text
                                           (concatenate 'string text
                                                        (view::render-elem
                                                         :paired t
                                                         :tag "option"
                                                         :attrs (if (equal (getf i :id) value)
                                                                    (list :value (getf i :id) :selected "selected")
                                                                    (list :value (getf i :id)))
                                                         :text (getf i :name)))))
                               text))))

;(show-fld-list "reason" 1)
;(show-fld-serialized 1)

(defun SHOW-FLD-SERIALIZED (value)
  (let* ((counter 0)
         (result
          (loop for i = 0 then (1+ j)
             as j = (position #\| value :start i)
             collect
               (let ((temp ())
                     (set (subseq value i j)))
                 (incf counter)
                 (loop for k = 0 then (1+ l)
                    as l = (position #\& set :start k)
                    do
                      (setf temp (append temp
                                         (let* ((pair (subseq set k l))
                                                (left (subseq pair
                                                              0 (position #\= pair)))
                                                (right (subseq pair
                                                               (1+ (position #\= pair)))))
                                           (list (intern (string-upcase left) :keyword) right))
                                         (list :id (concatenate
                                                    'string
                                                    "'clo-"
                                                    (write-to-string counter) "'"))))
                    while l)
                 temp)
             while j)))
    (tpl::fldlist (list :list result :clocount counter))))

(show-fld-serialized "category=cat1&brand=bra1&shop=sho1|category=cat2&brand=bra2&shop=sho2")

(defun show-photo (&optional id)
  (if (null id)
      (setf id ""))
  (view::render-elem :attrs (list :name "photo" :value id :type "hidden")))

