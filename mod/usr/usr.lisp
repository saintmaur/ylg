(restas:define-module #:usr
    (:use #:closer-mop #:cl #:iter #:alexandria #:anaphora #:postmodern #:lib)
  (:shadowing-import-from :closer-mop
                          :defclass
                          :defmethod
                          :standard-class
                          :ensure-generic-function
                          :defgeneric
                          :standard-generic-function
                          :class-name)
  (:export :*current-user* :registration :enter :logoff :email :password :takt :get-account))

(in-package #:usr)

(defparameter *current-user* nil)

(define-automat usr "Автомат пользователя"
  ((id           serial)
   (email        varchar)
   (password     varchar)
   (name         (or db-null varchar))
   (surname      (or db-null varchar)))
  (:logged :unlogged :link-sended)
  ((:logged       :unlogged     :logoff)      ;; Обнулить сессию
   (:unlogged     :logged       :none)       ;; Залогиниться
   (:unlogged     :link-sended  :none)  ;; Забыл пароль - пошлем линк
   (:link-sended  :logged       :enter))
  )

;; (print
;;  (macroexpand-1
;;   '(DEFINE-ENTITY USR "Автомат пользователя"
;;     ((ID SERIAL)
;;      (EMAIL VARCHAR)
;;      (PASSWORD VARCHAR)
;;      (NAME (OR DB-NULL VARCHAR))
;;      (SURNAME (OR DB-NULL VARCHAR))))))


(defun none ())

(defun generate-password ()
  (symbol-name (gensym "PASSWORD-")))

(defun registration (email)
  ;; TODO: Проверяеть email на валидность, если не валиден - сигнализировать err-param
  (when (get-account email)
    (return-from registration nil))
  (setf *current-user* (make-usr 'email email 'password (generate-password))))

(defun delete-account (email)
  ;; TODO: Проверять права, если проверка не прошла - сигнализировать err-permission
  (multiple-value-bind (match count) (find-usr :email email)
    (if (= count 0)
        nil
        (prog1 t
          (del-usr (id (first match)))))))

(defun get-account (email)
  (first (find-usr :email email)))

(defun all-accounts ()
  (all-usr))

(defun enter (login password)
  (multiple-value-bind (account cnt) (find-usr :email login)
    (if (= cnt 0)
        nil
        (when
            (or (string= password (password (first account))))
          (setf *current-user* (first account))
          t))))

(defun logoff ()
  (setf *current-user* nil)
  t)

;; Tests
;; Регистрация пользователя_1 — успешно
;; (assert (equal 'usr (type-of (registration "user_1@example.tld"))))

;; ;; ;; Регистрация пользователя_2 — успешно
;; (assert (equal 'usr (type-of (registration "user_2@example.tld"))))

;; ;; ;; Регистрация пользователя_3 — успешно
;; (assert (equal 'usr (type-of (registration "user_3@example.tld"))))

;; ;; ;; Регистрация пользователя_4 — успешно
;; (assert (equal 'usr (type-of (registration "user_4@example.tld"))))

;; ;; ;; Попытка регистрации пользователя_2 (повторная) — неуспешно
;; (assert (equal nil (registration "user_2@example.tld")))

;; ;; ;; Удаление аккунта пользователя_2 — успешно
;; (assert (equal t (delete-account "user_2@example.tld")))

;; ;; ;; Удаление аккунта пользователя_1 — успешно
;; ;; (assert (equal t (delete-account "user_1@example.tld")))

;; ;; ;; Попытка регистрации пользователя_2 (повторная после удаления) — успешно
;; ;; (assert (equal 'user (type-of (registration "user_2@example.tld"))))

;; ;; Получение аккаунта пользователя_3 — успешно
;; (assert (equal 'user (type-of (get-account "user_3@example.tld"))))

;; ;; Получение всех аккаунтов — существуют аккаунты пользователя_2, пользователя_3, пользователя_4, а аккаунт пользователя_1 — не существует
;; (assert (equal '("user_2@example.tld" "user_3@example.tld" "user_4@example.tld")
;;                (mapcar #'(lambda (x)
;;                            (email (car x)))
;;                        (all-accounts))))

;; ;; Выход из системы пользователя_3 — успешно
;; (assert (equal t (takt (get-account "user_3@example.tld") :unlogged :logoff)))

;; ;; Выход из системы пользователя_4 — успешно
;; (assert (equal t (takt (get-account "user_4@example.tld") :unlogged :logoff)))

;; ;; TODO:
;; ;; Отсылка пароля пользователю_4 — успешно
;; ;; Проверка состояния аккаунтов:
;; ;;     Пользователь_2 - залогинен
;; ;;     Пользователь_3 - незалогинен
;; ;;     Пользователь_4 - послан пароль
;; ;; Отсылка пароля пользователю_3 — успешно
;; ;; Попытка логина пользователя_3 с неправильным паролем — неуспешно
;; Попытка логина пользователя_3 с новым паролем — успешно
;; Попытка логина пользователя_2 со старым паролем — успешно
