(in-package #:ily)

(defun show-reasons (&optional reason)
  (if (null reason)
      (setf reason 0))
  (let ((reasons
         (with-connection ylg::*db-spec*
           (query
            (:select :* :from 'reasons) :plists))))
    (view::render-elem :paired t :tag "select" :attrs (list :name "reason")
                       :text (let ((text ""))
                               (loop for i in reasons
                                    do (setf text
                                             (concatenate 'string text
                                                          (view::render-elem
                                                           :paired t
                                                           :tag "option"
                                                           :attrs (if (equal (getf i :id) reason)
                                                                      (list :value (getf i :id) :selected "selected")
                                                                      (list :value (getf i :id)))
                                                           :text (getf i :name)))))
                               text))))
(defun show-id (&optional id)
  (if (null id)
      (setf id ""))
  (view::render-elem :attrs (list :name "id" :value id)))

(defun show-photo (&optional id)
  (if (null id)
      (setf id ""))
  (view::render-elem :attrs (list :name "photo" :value id)))

(defun show-goods (goods-str)
  )
(show-reason 1)
