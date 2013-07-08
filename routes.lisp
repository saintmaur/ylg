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
                  :right (ily:find-look :status 1)
                  :enterform (tpl:enterform)
                  :auth (if (null usr:*current-user*)
                            (tpl:authnotlogged)
                            (tpl:authlogged (list :username (usr:email usr:*current-user*) :password (usr:password usr:*current-user*)))))))

(restas:define-route file ("/file" :method :post)
  (awhen (hunchentoot:post-parameter "file")
    (destructuring-bind (path-name file-name file-type)
        it
      (let ((pic (pht:upload path-name (pathname-type (merge-pathnames path-name file-name)))))
        (json:encode-json-to-string (list
                                     (cons "photo" (concatenate 'string "/pic/" (pht::namefile pic)))
                                     (cons "id" (pht::id pic))))))))

(restas:define-route get-look ("/get-look" :method :post)
  (let ((data (alist-hash-table (hunchentoot:post-parameters*) :test #'equal)))
    (let* ((id (gethash "id" data))
           (look (first (ily::find-look :id id))))
      (json:encode-json-to-string (list
                                   (cons "id" (ily::id look))
                                   (cons "photo" (pht::get-pic-path (ily::photo look)))
                                   (cons "goods" (ily::goods look))
                                   (cons "user-id" (ily::user-id look))
                                   (cons "timestamp" (ily::timestamp look)))))))

(restas:define-route looks ("/looks")
  (tpl:root (list :left  (tpl:left)
                  :right (ily:show-look-list (ily:find-look :status 1))
                  :enterform (if (null usr:*current-user*)
                                 (tpl:enterform)
                                 nil)
                  :auth (if (null usr:*current-user*)
                            (tpl:authnotlogged)
                            (tpl:authlogged (list :username (usr:email usr:*current-user*)))))))



(restas:define-route one-look ("/look/:id")
  (tpl:root (list :left (tpl:left)
                  :right  (let ((look (first (ily:find-look :id id)))
                                (user (if usr::*current-user*
                                          (usr::id usr::*current-user*)
                                          0)))
                            (if (null look)
                                "No such data"
                                (progn
                                  (multiple-value-bind (form goods) (ily::show-fld-text (ily::goods look))
                                    (tpl:lookview (list
                                                   :id id
                                                   :pic (pht::get-pic-path :id (ily::photo look))
                                                   :voting (append (list
                                                                    :id id
                                                                    :entity "look"
                                                                    :pack "ily"
                                                                    :vote 1
                                                                    :voted (vot::check-if-voted
                                                                            :author user
                                                                            :entity 'ily::look
                                                                            :entity-id (parse-integer id)))
                                                                   (vot::vote-summary 'ily::look (parse-integer id)))
                           ;; :title (ily::title look)
                                                   :commenting (list
                                                                :entity "look"
                                                                :entid id
                                                                :pack "ily"
                                                                :comments (cmt::entity-comments 'ily::look (parse-integer id))
                                                                :currentuser user)
                                                   :timestamp (ily::timestamp look)
                                                  :goods goods
                                                  :editform form))))))
                            :enterform (if (null usr:*current-user*)
                                           (tpl:enterform)
                                           nil)
                            :auth (if (null usr:*current-user*)
                                      (tpl:authnotlogged)
                                      (tpl:authlogged (list :username (usr:email usr:*current-user*)))))))

  (restas:define-route vote ("/vote" :method :post)
    (let ((data (alist-hash-table (hunchentoot:post-parameters*) :test #'equal)))
      (let ((entity-id  (parse-integer (gethash "entity-id" data)))
          (entity (gethash "entity" data))
          (pack (gethash "pack" data))
          (vote (parse-integer (gethash "vote" data))))
      (if (and
           usr:*current-user*
           (vot::make-vote
            :entity (string-upcase entity)
            :entity-id entity-id
            :user-id (usr::id usr:*current-user*)
            :voting vote))
          ;; "ok"
          (json:encode-json-to-string (list
                                       (cons "passed" 1)
                                       (cons "msg" "Голос учтен")))
          ;; "err"
          (json:encode-json-to-string (list
                                       (cons "passed" 0)
                                       (cons "msg" "Ошибка доступа")))))))


(restas:define-route get-entity-votes ("/get-entity-votes" :method :post)
  (let ((data (alist-hash-table (hunchentoot:post-parameters*) :test #'equal)))
    (let* ((entity-id  (gethash "entity-id" data))
           (entity  (gethash "entity" data))
           (pack  (gethash "pack" data))
           (votes    (vot::vote-summary
                      (find-symbol (string-upcase entity) (find-package (string-upcase pack)))
                      (parse-integer entity-id))))
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

(restas:define-route save-look ("/save-look" :method :post)
  (let* ((data (alist-hash-table (hunchentoot:post-parameters*) :test #'equal))
         (id (gethash "id" data))
         (custom-reason (gethash "custom-reason" data))
         (reason (gethash "reason" data))
         (goods "")
         (photo (gethash "photo" data))
         (clo-count (parse-integer (gethash "clo-count" data)))
         (result 0)
         (look))
    (loop for i from 1 to clo-count
       do
         (setf goods (concatenate 'string goods "category="
                      (gethash (concatenate 'string "category-" (write-to-string i)) data) "&"))
         (setf goods (concatenate 'string goods "brand="
                        (gethash (concatenate 'string "brand-" (write-to-string i)) data) "&"))
         (setf goods (concatenate 'string goods "shop="
                      (gethash (concatenate 'string "shop-" (write-to-string i)) data)
                      (unless (= i clo-count) "|"))))
    (if (not (equal custom-reason ""))
        (with-connection ylg::*db-spec*
          (setf reason
                (or (query (:select :id :from 'reasons :where (:= 'name custom-reason)) :single)
                    (progn
                      (query (:insert-into 'reasons :set 'name custom-reason))
                      (query (:select :id :from 'reasons :where (:= 'name custom-reason)) :single))))))

    (if (equal id "")
        (progn
          (setf look
                (ily::make-look
                 :timestamp (get-universal-time)
                 :status (gethash "status" data)
                 :user_id (usr::id usr::*current-user*)
                 :reason reason
                 :photo photo
                 :goods goods))
          (unless (null look)
            (setf result 1)))
        (progn
          (setf look (ily::find-look :id id))
          (unless (null look)
            (setf look (ily::upd-look look
                                      (list
                                       :reason reason
                                       :photo photo
                                       :goods goods)))
            (setf result 1))))
    (json:encode-json-alist-to-string (list
                                       (cons "success" result)
                                       (cons "id" (ily::id look))))))


(restas:define-route save-comment ("/save-comment" :method :post)
  (let ((data (alist-hash-table (hunchentoot:post-parameters*) :test #'equal)))
    (let ( (entity-id (parse-integer (gethash "entity-id" data)))
          (id (parse-integer (gethash "id" data)))
           (author (parse-integer (gethash "author" data)))
           (text (gethash "text" data))
           (msg "")
           (result 0)
           (entity (gethash "entity" data))
           (pack (gethash "pack" data))
           (timestamp (get-universal-time)))
      (if (equal 0 author)
          (setf msg "Необходимо авторизоваться!")
      	  (progn
      	    (if (equal 0 id)
                (multiple-value-bind (new-obj new-id)
                    (cmt::make-comment
                     :text text
                     :author author
                     :entity-id entity-id
                     :entity (find-symbol (string-upcase entity) (find-package (string-upcase pack)))
                     :timestamp timestamp)
                  (setf id new-id)
                  (setf msg "успешно"))
                (let ((comment (cmt::find-comment :id id)))
                   (cmt::upd-cmt (get-dao 'comment id)
                                 (list
                                  (:text text)))))
            (setf result 1)))
      (json:encode-json-alist-to-string (list
                                         (cons "success" result)
                                         (cons "msg" msg)
                                         (cons "data" (if (not (equal 0 result))
                                                          (json:encode-json-alist-to-string
                                                           (list
                                                            (cons "text" text)
                                                            (cons "timestamp" timestamp)
                                                            (cons "author" (usr::email (usr::get-user author)))
                                                            (cons "id" id)
                                                            (cons "entity-id" entity-id)
                                                            (cons "vote" 1)
                                                            (cons "pack" pack)
                                                            (cons "entity" entity)
                                                            (cons "sum" (getf (vot::vote-summary (find-symbol (string-upcase entity) (find-package (string-upcase pack))) id) :sum))
                                                            (cons "like" (getf (vot::vote-summary (find-symbol (string-upcase entity) (find-package (string-upcase pack))) id) :like))
                                                            (cons "dislike" (getf (vot::vote-summary (find-symbol (string-upcase entity) (find-package (string-upcase pack))) id) :dislike))))
                                                          ())))))))

(restas:define-route del-comment ("/del-comment" :method :post)
  (let ((data (alist-hash-table (hunchentoot:post-parameters*) :test #'equal)))
    (let* ((id  (parse-integer (gethash "id" data)))
           (author  (cmt::author (cmt::get-comment id)))
           (msg "")
           (result (if (and
                        (equal author (usr::find-user usr::*current-user*))
                        (cmt::del-comment id))
                       (progn
                         (setf msg "успешно")
                         1)
                       (progn
                         (setf msg "Ошибка доступа. Скорей всего..")
                         0))))
      (json:encode-json-alist-to-string (list
                                         (cons "success" result)
                                         (cons "msg" msg))))))


(restas:define-route get-comment ("/get-comment" :method :post)
  (let ((data (alist-hash-table (hunchentoot:post-parameters*) :test #'equal)))
    (let* ((id  (parse-integer (gethash "id" data)))
           (cmt-data (cmt::get-comment-data id))
           (result 0))
      (when cmt-data
          (setf result 1))
      (json:encode-json-alist-to-string (list
                                         (cons "success" result)
                                         (cons "data" (json:encode-json-plist-to-string
                                                       cmt-data)))))))

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
