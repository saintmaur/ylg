(restas:define-module #:adv
    (:use #:closer-mop #:cl #:iter #:alexandria #:anaphora #:postmodern #:lib)
  (:shadowing-import-from :closer-mop
                          :defclass
                          :defmethod
                          :standard-class
                          :ensure-generic-function
                          :defgeneric
                          :standard-generic-function
                          :class-name)
  (:export :get-choice :all-choice :find-choice))

(in-package #:adv)

(define-automat choice "Автомат choice-а"
  ((id          serial)
   (timestamp   timestamp)
   (user_id     integer)
   (target      integer)
   (goods       varchar)
   (photo       integer))
  (:draft :public :archived)
  ((:draft   :public    :publish-choice)
   (:public  :archived  :archive-choice)))

(make-table)
;; (votes (get-choice 1))

;; (all-choice)

;; (find-choice #'(lambda (x)
;; 	       (equal (votes (car x)) 'votes2)))
;; View/Controller

;; (defun show-create ()
;;   "ook"
;;   t)

;; (defun show-edit ()
;;   "ook"
;;   t)

;; (defun show-choice ()
;;   "просмотр choice-а"
;;   t)

;; (defun show-choice-preview ()
;;   "review — просмотр миниатюры choice-а"
;;   t)

;; (defun action-publish ()
;;   "ook")

;; (defun action-delete ()
;;   "ook")

;; (defun action-vote ()
;;   "ook")




;; Tests

;; Owner создает choice,
;; загружает в него фотографии
;; и опционально добавляет данные (перечисленные в разделе "Данные").
;; Choice создается в состоянии draft
;; TODO: фотографию при загрузке можно редактировать фильтрами (js)
;; TODO: добавить крон на время голосования
;; (make-choice :timestamp (get-universal-time)
;;            :target '("club")
;;            :goods  '("shoes" "hat")
;;            :votes  'votes1
;;            :comments 'comments
;;            :state :draft)

;; (make-choice :timestamp (get-universal-time)
;;            :target '("club2")
;;            :goods  '("shoes2" "hat2")
;;            :votes  'votes2
;;            :comments 'comments
;;            :state :draft)

;; (assert (equal 'choice (type-of (get-choice 1))))

;; ;; (опционально) Owner редактирует choice, добавляя, удаляя или изменяя данные и фотографии.

;; (define-action edit-choice (flds)
;;   "редактирование choice-а owner-ом"
;;   ;; Проверка прав (around methods)
;;   ;; Проверка корректности данных (наличие, попадание в диапазон)
;;   ;; Замена полей choice-а
;;   )

;; Owner публикует choice, переводя его в состояние published. С этого момента choice можно комментировать и за него можно голосовать.
(defun publish-choice ()
  "публикация choice-a owner-ом"
  (print 'pub))

;; (takt (get-choice 1) :public :publish-choice)

;; (assert (equal :public (state (get-choice 1))))


;; Голосование
;; TODO

;; Архивирование choice-а
(defun archive-choice ()
  (print 'arch))

;; (takt (get-choice 1) :archived :archive-choice)

;; (assert (equal :archived (state (get-choice 1))))

;; ;; Удаление choice-а
;; (del-choice 1)

;; (assert (equal nil (ignore-errors (get-choice 1))))

;; ;; Список всех choice-ов

;; (all-choice)

;; ;; Показ конкретного choice-а

;; (get-choice)

;; Голосование

;; Попытка голосовать за лук не в том состоянии

;; Комментирование choice-а
