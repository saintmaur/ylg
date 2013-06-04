(in-package #:ylg)

(restas:define-route action-register ("/action-register" :method :post)
  (let ((data (alist-hash-table (hunchentoot:post-parameters*) :test #'equal)))
    (let ((user (usr:registration (gethash "login" data))))
      (if (null user)
          "account exists"
          (progn
            (usr:enter (usr:email user) (usr:password user))
            (json:encode-json-to-string (list (cons "location" "/"))))))))


(restas:define-route action-login ("/action-login" :method :post)
  (let ((data (alist-hash-table (hunchentoot:post-parameters*) :test #'equal)))
    (let ((login    (gethash "login" data))
          (password (gethash "password" data)))
      (if (usr:enter login password)
          ;; "ok"
          (json:encode-json-to-string (list
                                       (cons "passed" "true")
                                       (cons "location" "/")
                                       (cons "msg" "Добро пожаловать")))
          "Account not found"))))


(restas:define-route action-send-login ("/action-send-login" :method :post)
  (let ((data (alist-hash-table (hunchentoot:post-parameters*) :test #'equal)))
    (let* ((login    (gethash "login" data))
           (account  (usr::get-account login)))
      (unless (null account)
        (usr:takt account :link-sended :none)
        (usr:password account)))))


(restas:define-route action-logoff ("/action-logoff" :method :post)
  (usr:takt usr:*current-user* :unlogged :logoff)
  (json:encode-json-to-string (list (cons "location" "/"))))
