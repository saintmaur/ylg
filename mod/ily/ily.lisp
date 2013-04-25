(restas:define-module #:ily
    (:use #:closer-mop #:cl #:iter #:alexandria #:anaphora #:postmodern #:lib)
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
  ((timestamp :timestamp)
   (target    :target)
   (goods     :goods)
   (votes     :votes)
   (comments  :comments))
  (:draft :public :archived)
  ((:draft   :public    :publish-look)
   (:public  :archived  :archive-look)))


;; Model

(define-action edit-look (flds)
  "редактирование look-а owner-ом"
  ;; Проверка прав
  ;; Проверка корректности данных
  ;; Замена полей look-а
  )

(defun delete-look ()
  "удаление look-а owner-ом")

(defun publish-look ()
  "публикация look-a owner-ом")

(defun archive-look ()
  "перевод look-а в состояние archive owner-om")

(defun get-look ()
  "получение look-а (по id)")

(defun all-looks ()
  "получение всех look-ов (можно выбрать look-и по критериям, например только опубликованные)")

(defun vote-look ()
  "голосование за look")

;; View/Controller


(defun show-create ()
  "ook"
  t)

(defun show-edit ()
  "ook"
  t)

(defun show-look ()
  "просмотр look-а"
  t)

(defun show-look-preview ()
  "review — просмотр миниатюры look-а"
  t)

(defun action-publish ()
  "ook")

(defun action-delete ()
  "ook")

(defun action-vote ()
  "ook")


;; Tests

;; Создаем look
