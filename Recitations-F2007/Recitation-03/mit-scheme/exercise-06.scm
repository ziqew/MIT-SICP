;;
;; Exercise 6
;;
;; Write a procedure that computes the golden ratio, phi.
;;

;;
;; phi can be expressed as the limit of fib(n+1)/fib(n), as n tends to infinity.
;;
;; Knowing this, we can express our procedure for phi using the "fib" procedure as follows:
;;

;;
;; Define the "fib" procedure:
;;
(define (fib n)
  (cond ((= n 0) 1)
	((= n 1) 1)
	(else
	 (+ (fib (- n 1)) (fib (- n 2))))))

;;
;; Define the procedure to calculate "phi":
;;
(define (phi)
  (define tolerance 0.00001)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2)) tolerance))

  ;; use 1.0 multipliers here, to get the answer in decimal form
  (define (term n)
    (/ (* 1.0 (fib (+ n 1))) (* 1.0 (fib n))))

  (define (phi-iter c)
    (let ((first (term c))
	  (second (term (+ c 1))))
      (if (close-enough? first second)
	  second
	  (phi-iter (+ c 1)))))
  (phi-iter 0))

;;
;; Run the unit test:
;;
(phi)
;; ==> 1.618032786885246