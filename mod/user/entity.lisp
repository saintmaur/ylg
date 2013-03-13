;; macro-utils

(defmacro bprint (var)
  `(subseq (with-output-to-string (*standard-output*)  (pprint ,var)) 1))

(defmacro err (var)
  `(error (format nil "ERR:[~A]" (bprint ,var))))

(defmacro do-hash ((ht &optional (v 'v) (k 'k)) &body body)
  `(loop :for ,v :being :the :hash-values :in ,ht :using (hash-key ,k) :do
      ,@body))

(defmacro do-hash-collect ((ht &optional (v 'v) (k 'k)) &body body)
  `(loop :for ,v :being :the :hash-values :in ,ht :using (hash-key ,k) :collect
      ,@body))

(defmacro append-link (lst elt)
  `(setf ,lst (remove-duplicates (append ,lst (list ,elt)))))

(defun replace-all (string part replacement &key (test #'char=))
  "Returns a new string in which all the occurences of the part
 is replaced with replacement."
  (with-output-to-string (out)
    (loop with part-length = (length part)
       for old-pos = 0 then (+ pos part-length)
       for pos = (search part string
                         :start2 old-pos
                         :test test)
       do (write-string string out
                        :start old-pos
                        :end (or pos (length string)))
       when pos do (write-string replacement out)
       while pos)))


;; define-entity

(defmacro define-entity (name desc &rest tail)
  (let ((inc            (intern (concatenate 'string "INC-"     (symbol-name name) "-ID")))
        (incf-inc       (intern (concatenate 'string "INCF-"    (symbol-name name) "-ID")))
        (init-inc       (intern (concatenate 'string "INIT-"    (symbol-name name) "-ID")))
        (container      (intern (concatenate 'string "*"        (symbol-name name) "*")))
        (count-entity   (intern (concatenate 'string "COUNT-"   (symbol-name name))))
        (make-entity    (intern (concatenate 'string "MAKE-"    (symbol-name name))))
        (del-entity     (intern (concatenate 'string "DEL-"     (symbol-name name))))
        (all-entity     (intern (concatenate 'string "ALL-"     (symbol-name name))))
        (get-entity     (intern (concatenate 'string "GET-"     (symbol-name name))))
        (find-entity    (intern (concatenate 'string "FIND-"    (symbol-name name)))))
    `(let ((,inc 0))
       ;; incrementor
       (defun ,incf-inc ()
         (incf ,inc))
       ;; incrementor init
       (defun ,init-inc (init-value)
         (setf ,inc init-value))
       ;; container
       (defparameter ,container (make-hash-table :test #'equal))
       ;; container counter
       (defun ,count-entity ()
         (hash-table-count ,container))
       ;; class
       (defclass ,name ()
         ,(mapcar #'(lambda (x)
                      (list
                       (car x)
                       ;; :col-type (cadr x)
                       :initarg (intern (symbol-name (car x)) :keyword)
                       :initform (caddr x)
                       :accessor (car x)
                       ))
                  (car tail)))
       ;; make-entity
       (defun ,make-entity (&rest initargs)
         (let ((id (,incf-inc)))
           ;; todo: duplicate by id
           ;; todo: duplicate by fields
           (values
            (setf (gethash id ,container)
                  (apply #'make-instance
                         (list* ',name initargs)))
            id)))
       (defun ,del-entity (id)
         (remhash id ,container))
       (defun ,all-entity ()
         (do-hash-collect (,container)
           (cons v k)))
       ;; get-entity (by id, typesafe, not-present safe)
       (defun ,get-entity (var)
         (when (typep var 'integer)
           (multiple-value-bind (hash-val present-p)
               (gethash var ,container)
             (unless present-p
               (err 'not-present))
             (setf var hash-val)))
         (unless (typep var ',name)
           (err 'param-user-type-error))
         var)
       ;; find-entity - поиск айдишника по объекту
       (defmethod ,find-entity ((obj ,name))
         (do-hash (,container)
           (when (equal v obj)
             (return k))))
       ;; find-entity - поиск объекта по содержимому его полей
       (defmethod ,find-entity ((func function))
         (let ((rs))
           (mapcar #'(lambda (x)
                       (if (funcall func x)
                           (push x rs)))
                   (,all-entity))
           rs))
       )))

(defmacro define-automat (name desc &rest tail)
  `(progn
     (define-entity ,name ,desc
       ,(list* '(state :state) (car tail)))
     ,(let ((all-states (cadr tail)))
           `(progn
              ,@(loop :for (from-state to-state event body) :in (caddr tail) :collect
                   (if (or (null (find from-state all-states))
                           (null (find to-state all-states)))
                       (err (format nil "unknown state: ~A -> ~A" from-state to-state))
                       `(defmethod trans ((obj ,name)
                                          (from-state (eql ,from-state)) (to-state (eql ,to-state))
                                          (event (eql ,event)))
                          (prog1 ,body
                            (setf (state obj) ,to-state)))))
              (defmethod takt ((obj ,name) new-state event)
                (trans obj (state obj) new-state event))))))




(define-automat widget "Автомат виджета"
  ((name :str)
   (descr :str)
   (good :id)
   (blogger :id)
   (date :time)
   (amount :money)
   (sale-count :num)
   (price :money)
   (blogger-earning :money)
   (money-earned :money)
   (domain :str)
   (layout :str)
   (color :str)
   (sale-until :time))
  (:active :inactive :deleted)
  ((:active    :inactive  :blogger^widget-switch-off "блоггер: выключить виджет")
   (:inactive  :active    :blogger^widget-switch-on  "блоггер: включить виджет")
   (:active    :inactive  :cron^widget-switch-off    "крон: выключить виджет")
   (:active    :deleted   :blogger^widget-delete     "блоггер: удалить неактивный виджет")
   (:inactive  :deleted   :blogger^widget-delete     (print "блоггер: удалить неактивный виджет"))))


(make-widget
 :name    "Cool Jacket"
 :descr   "Jacket`s widget"
 :date    *cur-date*
 :good    (find-good (caar (find-good #'(lambda (x) (string= "Jacket" (name (car x)))))))
 :blogger 1
 :amount 100
 :sale-count 1
 :state :active
 :price 90
 :blogger-earning 5
 :domain :str)

(make-widget
 :name    "Nice Shirt"
 :descr   "Shirt`s widget"
 :date    *cur-date*
 :good    (find-good (caar (find-good #'(lambda (x) (string= "Shirt" (name (car x)))))))
 :blogger 1
 :amount 100
 :sale-count 1
 :state :inactive
 :price 90
 :blogger-earning 5
 :domain :str)

(make-widget
 :name    "Super Blazer"
 :descr   "Blazer`s widget"
 :date    *cur-date*
 :good    (find-good (caar (find-good #'(lambda (x) (string= "Blazer" (name (car x)))))))
 :blogger 2
 :amount 100
 :sale-count 1
 :state :deleted
 :price 90
 :blogger-earning 5
 :domain :str)







(define-entity buyer "Покупатель"
  ((name :str)
   (email :email)
   (zip :zip)
   (delivery-addr :str)
   (reg-date :time)
   (lastvisit :time)))

(define-entity blogger "Блоггер"
  ((name :str)
   (password :password)
   (email :email)
   (date :time)
   (lastvisit :time)
   (balance :money)
   (pending :money)
   (domain :domain)
   (activkey :activekey)))

(make-blogger
 :name      "Тестовый блоггер №1"
 :password  "blogger1"
 :email     "blogger1"
 :balance   1000
 :pending   2000
 :domain    "http://example2.com")

(make-blogger
 :name      "Тестовый блоггер №2"
 :password  "blogger2"
 :email     "blogger2"
 :balance   1000
 :pending   2000
 :domain    "http://example2.com")

(define-entity op "Оператор заказов"
  ((name :str)
   (password :password)))

(make-op
 :name      "Тестовый оператор №1"
 :password  "op1")

(define-entity gm "Модератор товаров"
  ((name :str)
   (password :password)))

(make-gm
 :name      "Тестовый модератор товаров №1"
 :password  "op1")

(define-entity adm "Админ"
  ((name :str)
   (password :password)))

(make-adm
 :name      "Тестовый админ №1"
 :password  "op1")



(define-automat order "Заказ"
  ((date :time)
   (cancel-flag :boolean)
   (cancel-previous-state :cancel-previous-state)
   (cancel-reason :str)
   (comission-charged :money)
   (comission-pending :money)
   (amount :money)
   (items-count :num)
   (widget :id)
   (buyer :id)
   (key :str))
  (:created :abandoned :paid :handed-store :handed-post :delivered :unprotested :protested :cancel :canceled)
  ((:created      :abandoned    :cron^payment-expired   "крон: истек строк оплаты")
   (:created      :paid         :blogger^paid           "блоггер: оплатить")
   ;; ----- paid
   (:paid         :cancel       :blogger^cancel         (prog1 "блоггер: отменить заказ"
                                                          (setf (cancel-flag obj) t)
                                                          (setf (cancel-previous-state) :paid)))
   (:cancel       :paid         :op^cancel-reject       "оператор: отказать в отмене заказа")

   (:paid         :handed-store :op^handed-store        "оператор: купить в магазине")
   ;; ------ handed-store
   (:handed-store :cancel       :blogger^cancel         (prog1 "блоггер: отменить заказ"
                                                          (setf (cancel-flag obj) t)
                                                          (setf (cancel-previous-state) :handed-store)))
   (:cancel       :handed-store :op^cancel-reject       "оператор: отказать в отмене заказа")
   (:handed-store :protested    :someone^protest        "кто-то: опротестовать")

   (:handed-store :handed-post  :op^handed-post         "оператор: присвоить почтовый идентификатор")
   ;; ----- handed-post
   (:handed-post  :cancel       :blogger^cancel         (prog1 "блоггер: отменить заказ"
                                                          (setf (cancel-flag obj) t)
                                                          (setf (cancel-previous-state) :handed-post)))
   (:cancel       :handed-post  :op^cancel-reject       "оператор: отказать в отмене заказа")
   (:handed-post  :protested    :someone^protest        "кто-то: опротестовать")

   (:handed-post  :delivered    :op^delivered           "оператор: доставлен")
   ;; ------ delivered
   (:delivered    :cancel       :blogger^cancel         (prog1 "блоггер: отменить заказ"
                                                          (setf (cancel-flag obj) t)
                                                          (setf (cancel-previous-state) :delivered)))
   (:cancel       :delivered    :op^cancel-reject       "оператор: отказать в отмене заказа")
   (:delivered    :protested    :someone^protest        "кто-то: опротестовать")
   ;; ----- unprotested & canceled
   (:delivered    :unprotested  :cron^unprotested       "крон: неопротестован")
   (:cancel       :canceled     :op^cancel-accept  "оператор: подтвердить отмену")))


(loop
   :for state
   :in '(:created :abandoned :paid :handed-store :handed-post :delivered :unprotested :protested :cancel :canceled)
   :do (make-order
        :state  state
        :cancel-previous-state :paid
        :amount 100
        :buyer  "some_buyer@yahoo.com"
        :widget 1))

(define-automat cashout "Заявка на вывод средств"
  ((date :time)
   (amount :money)
   (blogger :id))
  (:created :accepted :rejected)
  ((:created :rejected :op^cashout-reject "оператор: отказать в выводе")
   (:created :accepted :op^cashout-accept "оператор: подтвердить вывод")))


(loop
   :for state
   :in '(:created :accepted :rejected)
   :do  (make-cashout
         :state state
         :amount 100
         :blogger 1
         :state :created))


(defparameter *actor* (get-blogger 1))
