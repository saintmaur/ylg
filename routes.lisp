(in-package #:ylg)

;; 404

;; (defun page-404 (&optional (title "404 Not Found") (content "Страница не найдена"))
;;   (let* ((title "404 Not Found")
;;          (menu-memo (menu)))
;;     (restas:render-object
;;      (make-instance 'ylg-render)
;;      (list title
;;            menu-memo
;;            (tpl:default
;;                (list :title title
;;                      :navpoints menu-memo
;;                      :content "Страница не найдена"))))))

;; (restas:define-route not-found-route ("*any")
;;   (restas:abort-route-handler
;;    (page-404)
;;    :return-code hunchentoot:+http-not-found+
;;    :content-type "text/html"))


;; main

(restas:define-route main ("/")
  (tpl:root (list :left (tpl:left)
                  :right (tpl:right)
                  :enterform (tpl:enterform)
                  :auth (if (null usr:*current-user*)
                            (tpl:authnotlogged)
                            (tpl:authlogged (list :username (usr:email usr:*current-user*)))))))

(restas:define-route ajax-register ("/ajax-register" :method :post)
  (let ((data (alist-hash-table (hunchentoot:post-parameters*) :test #'equal)))
    (let ((user (usr:registration (gethash "login" data))))
      (if (null user)
          "account exists"
          (progn
            (usr:enter (usr:email user) (usr:password user))
            (json:encode-json-to-string (list (cons "location" "/"))))))))


(restas:define-route ajax-enter ("/ajax-enter" :method :post)
  (let ((data (alist-hash-table (hunchentoot:post-parameters*) :test #'equal)))
    (let ((login    (gethash "login" data))
          (password (gethash "pass" data)))
      (if (usr:enter login password)
          (json:encode-json-to-string (list (cons "location" "/")))
          "err"))))

(restas:define-route ajax-send-login ("/ajax-send-login" :method :post)
  (let ((data (alist-hash-table (hunchentoot:post-parameters*) :test #'equal)))
    (let ((login    (gethash "login" data)))
      (usr:send-login login))))


(restas:define-route ajax-logoff ("/ajax-logoff" :method :post)
  (usr:logoff)
  (json:encode-json-to-string (list (cons "location" "/"))))

(restas:define-route looks ("/looks")
  (tpl:root (list :left (tpl:left)
		  ;;  TODO: pass a valid list of looks + how to get a field from a look obj inside tmpl
                  :right (tpl:lookslist  (mapcar #'(lambda (look-pair)
						     (let ((look (car look-pair))
							   (id (cdr look-pair)))
						       (list
							:id id
							:timestamp (ily::timestamp look)
							:target (ily::target look)
							:votes (ily::votes look))))
						 (ily:all-look)))
                  :enterform (if (null usr:*current-user*)
				 (tpl:enterform)
				 nil)
                  :auth (if (null usr:*current-user*)
                            (tpl:authnotlogged)
                            (tpl:authlogged (list :username (usr:email usr:*current-user*)))))))

(restas:define-route looks ("/look/:id")
  (tpl:root (list :left (tpl:left)
		  ;;  TODO: pass a valid list of looks + how to get a field from a look obj inside tmpl
                  :right (if (null (setf look (ily:get-look id)))
			     ("No such data")
			     (tpl:lookview (list :photo (getf look photo) :title (getf look title) :goods (getf look goods))))
                  :enterform (if (null usr:*current-user*)
				 (tpl:enterform)
				 nil)
                  :auth (if (null usr:*current-user*)
                            (tpl:authnotlogged)
                            (tpl:authlogged (list :username (usr:email usr:*current-user*)))))))

;; plan file pages

(defmacro def/route (name param &body body)
  `(progn
     (restas:define-route ,name ,param
       ,@body)
     (restas:define-route
         ,(intern (concatenate 'string (symbol-name name) "/"))
         ,(cons (concatenate 'string (car param) "/") (cdr param))
       ,@body)))


;; (def/route about ("about")
;;   (path "content/about.org"))


;ily routes

(restas:mount-submodule -css- (#:restas.directory-publisher)
  (restas.directory-publisher:*baseurl* '("css"))
  (restas.directory-publisher:*directory* (path "css/")))

(restas:mount-submodule -js- (#:restas.directory-publisher)
  (restas.directory-publisher:*baseurl* '("js"))
  (restas.directory-publisher:*directory* (path "js/")))

(restas:mount-submodule -img- (#:restas.directory-publisher)
  (restas.directory-publisher:*baseurl* '("img"))
  (restas.directory-publisher:*directory* (path "img/")))
