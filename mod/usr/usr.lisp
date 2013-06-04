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

(define-automat user "Автомат пользователя"
  ((email        :email)
   (password     :password)
   (new-password :password))
  (:logged :unlogged :link-sended)
  ((:logged       :unlogged     :logoff)      ;; Обнулить сессию
   (:unlogged     :logged       :none)       ;; Залогиниться
   (:unlogged     :link-sended  :none)  ;; Забыл пароль - пошлем линк
   (:link-sended  :logged       :enter)))     ;; Залогиниться

(defun none ())

(defun generate-password ()
  (symbol-name (gensym "PASSWORD-")))

(defun registration (email)
  ;; TODO: Проверяеть email на валидность, если не валиден - сигнализировать err-param
  ;; Если есть уже такой email - возвращать nil
  (when (get-account email)
    (return-from registration nil))
  (make-user :email email :password (generate-password) :state :logged))

(defun delete-account (email)
  ;; TODO: Проверять права, если проверка не прошла - сигнализировать err-permission
  (let ((match (find-user #'(lambda (x) (equal (email (car x)) email)))))
    (if (null match)
        nil
        (prog1 t
          (mapcar #'(lambda (x)
                      (del-user (cdr x)))
                  match)))))

(defun get-account (email)
  (caar (find-user #'(lambda (x)
                       (equal (email (car x)) email)))))

(defun all-accounts ()
  (all-user))


(defun enter (login password)
  (let ((account (get-account login)))
    (if (null account)
        nil
        (when
            (or (string= password (password account))
                (string= password (new-password account)))
          (setf (password account) password)
          (setf (new-password account) "")
          (setf *current-user* account)
          (setf (state *current-user*) :logged)
          t))))


(defun logoff ()
  (when (not (null *current-user*))
    (setf (state *current-user*) :unlogged))
  (setf *current-user* nil)
  t)

;; Tests

;; Регистрация пользователя_1 — успешно
(assert (equal 'user (type-of (registration "user_1@example.tld"))))

;; Регистрация пользователя_2 — успешно
(assert (equal 'user (type-of (registration "user_2@example.tld"))))

;; Регистрация пользователя_3 — успешно
(assert (equal 'user (type-of (registration "user_3@example.tld"))))

;; Регистрация пользователя_4 — успешно
(assert (equal 'user (type-of (registration "user_4@example.tld"))))

;; Попытка регистрации пользователя_2 (повторная) — неуспешно
(assert (equal nil (registration "user_2@example.tld")))

;; Удаление аккунта пользователя_2 — успешно
(assert (equal t (delete-account "user_2@example.tld")))

;; Удаление аккунта пользователя_1 — успешно
(assert (equal t (delete-account "user_1@example.tld")))

;; Попытка регистрации пользователя_2 (повторная после удаления) — успешно
(assert (equal 'user (type-of (registration "user_2@example.tld"))))

;; Получение аккаунта пользователя_3 — успешно
(assert (equal 'user (type-of (get-account "user_3@example.tld"))))

;; Получение всех аккаунтов — существуют аккаунты пользователя_2, пользователя_3, пользователя_4, а аккаунт пользователя_1 — не существует
(assert (equal '("user_2@example.tld" "user_3@example.tld" "user_4@example.tld")
               (mapcar #'(lambda (x)
                           (email (car x)))
                       (all-accounts))))

;; Выход из системы пользователя_3 — успешно
(assert (equal t (takt (get-account "user_3@example.tld") :unlogged :logoff)))

;; Выход из системы пользователя_4 — успешно
(assert (equal t (takt (get-account "user_4@example.tld") :unlogged :logoff)))

;; TODO:
;; Отсылка пароля пользователю_4 — успешно
;; Проверка состояния аккаунтов:
;;     Пользователь_2 - залогинен
;;     Пользователь_3 - незалогинен
;;     Пользователь_4 - послан пароль
;; Отсылка пароля пользователю_3 — успешно
;; Попытка логина пользователя_3 с неправильным паролем — неуспешно
;; Попытка логина пользователя_3 с новым паролем — успешно
;; Попытка логина пользователя_2 со старым паролем — успешно
