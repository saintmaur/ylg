(restas:define-module #:usr
    (:use #:closer-mop #:cl #:iter #:alexandria #:anaphora #:postmodern)
  (:shadowing-import-from :closer-mop
                          :defclass
                          :defmethod
                          :standard-class
                          :ensure-generic-function
                          :defgeneric
                          :standard-generic-function
                          :class-name))

(in-package #:usr)

(define-automat user "Автомат пользователя"
  ((email        :email)
   (password     :password)
   (new-password :password))
  (:logged :unlogged :link-sended)
  ((:logged       :unlogged     :leave)       ;; Обнулить сессию
   (:unlogged     :logged       :enter)       ;; Залогиниться
   (:unlogged     :link-sended  :send-login)  ;; Забыл пароль - пошлем линк
   (:link-sended  :logged       :enter)))     ;; Залогиниться


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

(define-action enter (email password)
  (let ((data (get-account email)))
    (when (null data)
      (return-from enter nil))
    (when (or (string= password (password data))
              (string= password (new-password data)))
      (setf (password data) password)
      (setf (new-password data) "")
      (setf *current-user* data)
      t)))

(define-action leave ()
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
(assert (equal t (takt (get-account "user_3@example.tld") :unlogged :leave)))

;; Выход из системы пользователя_4 — успешно
(assert (equal t (takt (get-account "user_4@example.tld") :unlogged :leave)))

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


;; (define-action send-login (GET email)
;;   (request-protect
;;    (let ((data (get-user email)))
;;      ;; TODO: compile and store link ??
;;      (send-email (getf data :email) link)
;;      (setf (getf data :state) :link-sended))))

;; (define-action need-change-password (GET token)
;;   (request-protect
;;    (let ((data (get-user token)))
;;      (setf (getf data :state) :logged-for-change-password))))

;; (define-action change-pass (POST token oldpassword newpassword)
;;   (request-protect
;;    (let ((data (get-user token)))
;;      (if (getf data :password)==oldpassword
;;          ((setf (getf data :password) newpassword)
;;           (setf (getf session :token) (token data))
;;           (setf (getf data :state) :logged-for-change-password))
;;          (return "401 Unauthorized")))))

;; (define-action setf ())
;; (define-action getf ())

;; (define-action destroy-user (login password))

;; (define-action token ())

;; (define-action get-user ())

;; ((200 "Ok" <some-data>)
;;  (404 "Not Found")       ;; login not found
;;  (403 "Forbidden"))))    ;; password wrong
