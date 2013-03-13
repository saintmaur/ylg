
(define-automat user "Автомат пользователя"
  ((email        :email)
   (password     :password)
   (new-password :password))
  (:logged :unlogged :link-sended)
  ((:logged       :unlogged     :leave       "Обнулить сессию")
   (:unlogged     :logged       :enter       "Залогиниться")
   (:unlogged     :link-sended  :send-login  "Забыл пароль - пошлем линк")
   (:link-sended  :logged       :enter       "Залогиниться")))


(defun generate-password ()
  (symbol-name (gensym "PASSWORD-")))

(defun registration (email)
  ;; TODO: Проверяеть email на валидность, если не валиден - сигнализировать err-param
  ;; TODO: Проверять, есть ли уже такой email, если есть - возвращать nil
  (make-user :email email :password (generate-password) :state :logged))

(defun delete-account (email)
  ;; TODO: Проверять права, если проверка не прошла - сигнализировать err-permission
  (let ((match (find-user #'(lambda (x)
                              (equal (email (car x)) email)))))
    (if (null match)
        nil
        (prog1 t
          (mapcar #'(lambda (x)
                      (del-user (cdr x)))
                  match)))))

(defun get-account (email)
  (caar
   (find-user #'(lambda (x)
                  (equal (email (car x)) email)))))


;; Tests

;; Регистрация пользователя_1 — успешно
(assert (equal 'user (type-of (registration "user_1@example.tld"))))

;; Регистрация пользователя_2 — успешно
(assert (equal 'user (type-of (registration "user_2@example.tld"))))

;; Регистрация пользователя_3 — успешно
(assert (equal 'user (type-of (registration "user_3@example.tld"))))

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

;; Получение всех аккаунтов — существуют аккаунты пользователя_2 и пользователя_3, аккаунт пользователя_1 — не существует
;; Вход в систему пользователя_2 — успешно
;; Вход в систему пользователя_3 — успешно
;; Попытка входа в систему пользователя_1 — неуспешно
;; Проверка состояния аккаунта пользователя_2 - залогинен
;; Выход из системы пользователя_2 — успешно
;; Отсылка логина пользователю_3 — успешно
;; Получение всех пользователей и анализ из состояния — пользователь_2 незалогинен, пользователь_3 - послан пароль


(define-automat user-auth "Автомат авторизации пользователя"
  (:logged :unlogged :link-sended :logged-for-change-password)
  ((:logged       :unlogged     :leave       "Обнулить сессию")
   (:unlogged     :logged       :enter       "Залогиниться")
   (:unlogged     :link-sended  :send-login  "Забыл пароль - пошлем линк")
   (:link-sended  :logged       :enter       "Залогиниться")))

(define-action enter (GET token)
  (request-protect
   (let ((data (get-user token)))
     (setf (getf data :state) :logged-out)
     (destroy-session))))

(define-action leave (POST login password)
  (request-protect
   (let ((data (get-user login password)))
     (setf (getf data :state) :logged-in)
     (setf (getf session :token) (token data)))))

(define-action send-login (GET email)
  (request-protect
   (let ((data (get-user email)))
     ;; TODO: compile and store link ??
     (send-email (getf data :email) link)
     (setf (getf data :state) :link-sended))))

(define-action need-change-password (GET token)
  (request-protect
   (let ((data (get-user token)))
     (setf (getf data :state) :logged-for-change-password))))

(define-action change-pass (POST token oldpassword newpassword)
  (request-protect
   (let ((data (get-user token)))
     (if (getf data :password)==oldpassword
         ((setf (getf data :password) newpassword)
          (setf (getf session :token) (token data))
          (setf (getf data :state) :logged-for-change-password))
         (return "401 Unauthorized")))))

(define-action setf ())
(define-action getf ())

(define-action destroy-user (login password))

(define-action token ())

(define-action get-user ())

((200 "Ok" <some-data>)
 (404 "Not Found")       ;; login not found
 (403 "Forbidden"))))    ;; password wrong
