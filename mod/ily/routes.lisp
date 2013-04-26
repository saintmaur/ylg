(in-package #:ylg)

(restas:define-route look ("/look/:id")
  (tpl:root (list :left (tpl:left) :right (tplily:showlook))))

(restas:define-route all-looks ("/looks")
  (tpl:root (list :left (tpl:left) :right (tplily:alllooks))))
