#lang r7rs

; eval of empty list is an error
; ()

(define x 1)
; (define y math)
(define z "foobar")
(define a car)
; (quote)
; (quote 1 2)
(car '(42 84 168))

; (lambda)
; (lambda 42 42)
; (lambda (x y z))
; (lambda (x y z . w))

(lambda () 42)
(lambda (x) (car x))
(lambda (x y z) (car y))
(lambda (x y z . w)
  (write x)
  (write w))

(define (foo x y)
  42)
(define (bar x)
  (assert #f))
(define (quux)
  (assert #f))
(define (colbert . stewart)
  (write stewart))
(define (test1 arg0 arg1 . stewart)
  (write stewart)
  (test1 (car stewart)))
;(bar 1)
(colbert 1 2 3)

; (if)
; (if #t)
(if #t
  1)
(if #f
  1)
(if #t
  1
  2)
(if #f
  1
  2)
(if nil
  "yes, nil is true!"
  2)
((lambda (x)
   (if nil
     "yes, nil is true!"
     2)
   (if #f
     "yes, nil is true!"
     2)) 5)
(if #t
  (if #t 1 2)
  (if #f 3 4))

;(let foo ((x 1)
;      (y 1))
;  (foo))
(let ((x 1)
      (y 1))
  x)
(let ((x 1)
      (y 1))
  (foo))
(let* ((x 1)
       (y 1))
  x)
(let* ((x 1)
       (y 1))
  (foo))
(letrec ((x 1)
         (y 1))
  x)
(letrec ((x 1)
         (y 1))
  (foo x y))
(letrec ((x 1)

         (y 1))
  (foo x y))
;; from page 16 of r7rs.pdf
; this should == 5
(letrec ((p
           (lambda (x)
             (+ 1 (q (- x 1)))))
          (q
           (lambda (y)
             (if (zero? y)
                 0
                 (+ 1 (p (- y 1))))))
          (x (p 5))
          (y x))
         y)

