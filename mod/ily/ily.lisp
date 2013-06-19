(restas:define-module #:ily
    (:use #:closer-mop #:cl #:iter #:alexandria #:anaphora #:postmodern #:lib)
  (:shadowing-import-from :closer-mop
                          :defclass
                          :defmethod
                          :standard-class
                          :ensure-generic-function
                          :defgeneric
                          :standard-generic-function
                          :class-name)
  (:export :get-look :all-look :find-look :vote-look :show-look-list))

(in-package #:ily)

;(closure-template:compile-template :common-lisp-backend (ylg:path "mod/ily/tpl.htm"))

(define-automat look "Автомат look-а"
  ((timestamp   :timestamp)
   (target      :target)
   (goods       :goods)
   (photo         :photo))
  (:draft :public :archived)
  ((:draft   :public    :publish-look)
   (:public  :archived  :archive-look)))

(db-init::init-table-class
 ((id :col-type serial :initarg id :accessor id)
  (user-id :col-type integer :initarg user-id :accessor user-id :foreign-key (users id))
  (target :col-type text :initarg :target :accessor target)
  (goods :col-type text :initarg :goods :accessor goods)
  (timestamp :col-type timestamp :initarg :timestamp :accessor timestamp))
 :table "look")

(init-table)

(defun show-look-list (looks)
  (tpl:lookslist (list :looks (mapcar #'(lambda (look-pair)
                                          (let ((look (car look-pair))
                                                (id (cdr look-pair)))
                                            (list :id id
                                                  :timestamp (ily::timestamp look)
                                                  :target (ily::target look)
                                                  :photo (ily::photo look)
                                                  )))
                                      looks))))
;; (defun vote-look (look-id voting &optional (current-user usr:*current-user*))
;;   (let ((vote (vot:make-vote :entity-id look-id
;;                              :entity 'look
;;                              :user-id (usr::find-user (usr::get-user current-user))
;;                              :voting voting))
;;         (look (get-look look-id)))
;;     (setf (votes look)
;;           (append (votes look)
;;                   (list (vot:find-vote vote))))))


;;(vote-look 1 1 3)

;;(vot::vote-summary 'ily::look 1)
;; (votes (get-look 1))
;; (vot:all-vote)
;; (vot:entity-id (vot:get-vote 3))
;; (vot:entity-id (vot::get-vote 2))


;; (defun show-create ()
;;   "ook"
;;   t)

;; (defun show-edit ()
;;   "ook"
;;   t)

;; (defun show-look ()
;;   "просмотр look-а"
;;   t)

;; (defun show-look-preview ()
;;   "review — просмотр миниатюры look-а"
;;   t)

;; (defun action-publish ()
;;   "ook")

;; (defun action-delete ()
;;   "ook")

;; (defun action-vote ()
;;   "ook")





;; Tests

;; Owner создает look,
;; загружает в него фотографии
;; и опционально добавляет данные (перечисленные в разделе "Данные").
;; Look создается в состоянии draft
;; TODO: фотографию при загрузке можно редактировать фильтрами (js)
;; TODO: добавить крон на время голосования
(make-look :timestamp (get-universal-time)
           :target '("club")
           :goods  '("shoes" "hat")
           :photo "1.jpg"
           :state :draft)


(make-look :timestamp (get-universal-time)
           :target '("club2")
           :goods  '(("shoes2" "brand" "shop") ("hat2"))
           :photo "2.jpg"
           :state :draft)

(make-look :timestamp (get-universal-time)
           :target '("club2")
           :goods  '(("shoes2" "brand" "shop") ("hat2"))
           :photo "3.jpg"
           :state :draft)

(make-look :timestamp (get-universal-time)
           :target '("club2")
           :goods  '(("shoes2" "brand" "shop") ("hat2"))
           :photo "4.jpg"
           :state :draft)

(assert (equal 'look (type-of (get-look 1))))

;; ;; (опционально) Owner редактирует look, добавляя, удаляя или изменяя данные и фотографии.

;; (define-action edit-look (flds)
;;   "редактирование look-а owner-ом"
;;   ;; Проверка прав (around methods)
;;   ;; Проверка корректности данных (наличие, попадание в диапазон)
;;   ;; Замена полей look-а
;;   )

;; Owner публикует look, переводя его в состояние published. С этого момента look можно комментировать и за него можно голосовать.
(defun publish-look ()
  "публикация look-a owner-ом"
  (print 'pub))

(takt (get-look 1) :public :publish-look)
(takt (get-look 2) :public :publish-look)
(takt (get-look 3) :public :publish-look)
(takt (get-look 4) :public :publish-look)



(assert (equal :public (state (get-look 1))))


;; Голосование
;; TODO

;; Архивирование look-а
(defun archive-look ()
  (print 'arch))

(takt (get-look 1) :archived :archive-look)

(assert (equal :archived (state (get-look 1))))

;; ;; Удаление look-а
;; (del-look 1)

;; (assert (equal nil (ignore-errors (get-look 1))))

;; ;; Список всех look-ов

;; (all-look)

;; ;; Показ конкретного look-а

;; (get-look)

;; Голосование

;; Попытка голосовать за лук не в том состоянии

;; Комментирование look-а
