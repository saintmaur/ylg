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
    (let ((login    (gethash "login" data)))
      (usr:send-login login))))


(restas:define-route action-logoff ("/action-logoff" :method :post)
  (usr:logoff)
  (json:encode-json-to-string (list (cons "location" "/"))))


(restas:define-route file ("/file" :method :post)
  (awhen (hunchentoot:post-parameter "file")
    (destructuring-bind (pathname filename format)
        it
      (let ((pic (pht:upload pathname filename format)))
        (format nil "uploaded ~A at ~A (time: ~A)"
                (pht::uploadfilename pic)
                (pht::pathnamefile pic)
                (pht::timestamp pic))
        (json:encode-json-to-string (list (cons "photo" (concatenate 'string "/pic/" (pht::namefile pic)))))
        ;; "{photo : pic/1.jpg}"
        )
      ;; "{\"photo\" : \"pic/1.jpg\"}"
      )))


(restas:define-route looks ("/looks")
  (tpl:root (list :left  (tpl:left)
                  :right (ily:show-look-list (ily:find-look #'(lambda (x)
                                                                (and (equal (ily::state (car x)) :public)
                                                                     (equal (ily::state (car x)) :archive)))))
                  :enterform (if (null usr:*current-user*)
                                 (tpl:enterform)
                                 nil)
                  :auth (if (null usr:*current-user*)
                            (tpl:authnotlogged)
                            (tpl:authlogged (list :username (usr:email usr:*current-user*)))))))

(restas:define-route one-look ("/look/:id")
  (tpl:root (list :left (tpl:left)
                  :right  (let ((look (ily:get-look (parse-integer id))))
                            (if (null look)
                                "No such data"
                                (tpl:lookview (list
                                               :id id
                                               :pic (ily::pic look)
					       :voting (append (list :id id :entity "look" :vote 1) (vot::vote-summary 'ily::look (parse-integer id))) ;;TODO :vote may differ for simple users and stylist, etc.
                                               ;; :title (ily::title look)
					       :commenting (list
							    :entity "look"
							    :entid id
							    :pack "ily"
							    :comments (cmt::entity-comments 'ily::look (parse-integer id))
							    :currentuser (if usr::*current-user*
									     (usr::find-user usr::*current-user*)
									     ""))
                                               :timestamp (ily::timestamp look)
                                               :goods (ily::goods look)))))
                  :enterform (if (null usr:*current-user*)
                                 (tpl:enterform)
                                 nil)
                  :auth (if (null usr:*current-user*)
                            (tpl:authnotlogged)
                            (tpl:authlogged (list :username (usr:email usr:*current-user*)))))))


(restas:define-route action-vote-look ("/action-vote-look" :method :post)
  (let ((data (alist-hash-table (hunchentoot:post-parameters*) :test #'equal)))
    (let ((look-id    (gethash "look-id" data))
          (vote       (gethash "vote" data)))
      (if (and
	   usr:*current-user*
	   (ily:vote-look (parse-integer look-id) (parse-integer vote) usr:*current-user*))
          ;; "ok"
          (json:encode-json-to-string (list
                                       (cons "passed" 1)
                                       (cons "location" "/")
                                       (cons "msg" "Голос учтен")))
          ;; "err"
          (json:encode-json-to-string (list
                                       (cons "passed" 0)
                                       (cons "msg" "Ошибка доступа")))))))

(restas:define-route get-votes-look ("/get-votes-look" :method :post)
  (let ((data (alist-hash-table (hunchentoot:post-parameters*) :test #'equal)))
    (let* ((look-id  (gethash "look-id" data))
           (votes    (vot::vote-summary 'ily::look (parse-integer look-id))))
      (json:encode-json-alist-to-string (list
					 (cons "success" "true")
					 (cons "like" (getf votes :like))
					 (cons "sum" (getf votes :sum))
					 (cons "dislike" (getf votes :dislike)))))))


(restas:define-route choices ("/choices")
  (tpl:root (list :left (tpl:left)
                  :right (tpl:choiceslist (list :choices (mapcar #'(lambda (choice-pair)
                                                                 (let ((choice (car choice-pair))
                                                                       (id (cdr choice-pair)))
                                                                   (list :id id
                                                                         :timestamp (adv::timestamp choice)
                                                                         :target (adv::target choice)
                                                                         :votes (adv::votes choice))))
                                                             (adv:all-choice))))
                  :enterform (if (null usr:*current-user*)
                                 (tpl:enterform)
                                 nil)
                  :auth (if (null usr:*current-user*)
                            (tpl:authnotlogged)
                            (tpl:authlogged (list :username (usr:email usr:*current-user*)))))))

(restas:define-route one-choice ("/choice/:id")
  (tpl:root (list :left (tpl:left)
                  :right  (let ((choice (adv:get-choice (parse-integer id))))
                            (if (null choice)
                                "No such data"
                                (tpl:choiceview (list
                                               :id id
                                               ;; :photo (adv::photo choice)
                                               ;; :title (adv::title choice)
                                               :timestamp (adv::timestamp choice)
                                               :goods (adv::goods choice)))))
                  :enterform (if (null usr:*current-user*)
                                 (tpl:enterform)
                                 nil)
                  :auth (if (null usr:*current-user*)
                            (tpl:authnotlogged)
                            (tpl:authlogged (list :username (usr:email usr:*current-user*)))))))



(restas:define-route save-comment ("/save-comment" :method :post)
  (let ((data (alist-hash-table (hunchentoot:post-parameters*) :test #'equal)))
    (let ( (entity-id (parse-integer (gethash "entity-id" data)))
	   (id (parse-integer (gethash "id" data)))
	   (author (gethash "author" data))
	   (text (gethash "text" data))
	   (msg "")
	   (result 0)
	   (entity (gethash "entity" data))
	   (pack (gethash "pack" data))
	   (timestamp (get-universal-time)))
      (if (equal "" author)
	  (setf msg "Необходимо авторизоваться!")
      	  (progn
      	    (if (equal 0 id)
		(multiple-value-bind (new-obj new-id)
		    (cmt::make-comment
		     :text text
		     :author (parse-integer author)
		     :entity-id entity-id
		     :entity (find-symbol (string-upcase entity) (find-package (string-upcase pack)))
		     :timestamp (get-universal-time))
		  (setf id new-id)
		  (setf msg "успешно"))
      		(let ((comment (cmt::find-comment id)))
      		  (setf (cmt::text comment) text)
		  (setf timestamp (cmt::timestamp comment))))
	    (setf result 1)))
      (json:encode-json-alist-to-string (list
					 (cons "success" result)
					 (cons "msg" msg)
					 (cons "data" (json:encode-json-alist-to-string
					 	       (list
					 		(cons "text" text)
					 		(cons "timestamp" timestamp)
					 		(cons "author" author)
					 		(cons "id" id)
					 		(cons "entity-id" entity-id)
							(cons "pack" pack)
							(cons "entity" entity)))))))))



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

(restas:mount-submodule -pic- (#:restas.directory-publisher)
  (restas.directory-publisher:*baseurl* '("pic"))
  (restas.directory-publisher:*directory* (path "pic/")))
