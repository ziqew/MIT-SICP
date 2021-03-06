;;
;; Exercise 2.19
;;
;; Consider the change-counting program of section 1.2.2. It would be nice to be able to easily
;; change the currency used by the program, so that we could compute the number of ways to 
;; change a British pound, for example. As the program is written, the knowledge of the currency
;; is distributed partly into the procedure "first-denomination" and partly into the procedure
;; "count-change" (which knows that there are give kinds of U.S. coins). It would be nicer to be 
;; able to supply a list of coins to be used for naking change.
;;
;; We want to rewrite the procedure "cc" so that its second argument is a list of the values of the 
;; coins to use rather than an integer specifying which coins to use. We could then have lists that
;; defined each kind of currency:
;;
;; (define us-coins (list 50 25 10 5 1))
;; (define uk-coins (list 100 50 20 10 5 2 1 0.5))
;;
;; We could then call "cc" as follows:
;;
;; (cc 100 us-coins)
;; ==>292
;;
;; To do this will require changing the program "cc" somewhat. It will still have the same form, but 
;; it will access its second argument differently, as follows:
;;
;; (define (cc amount coins-values)
;;  (cond ((= amount 0) 1)
;;        ((or (< amount 0) (no-more? coin-values)) 0)
;;        (else
;;         (+ (cc amount
;;                (except-first-denomination coin-values))
;;            (cc (- amount
;;                   (first-denomination coin-values))
;;                 coin-values)))))
;;
;; Define the procedures "first-denomination", "except-first-denomination" and "no-more?" in terms
;; of primitive operations on list structures. Does the order of the list "coin-values" affect the 
;; answer produced by "cc"? Why or why not?
;;

;;
;; For reference, the "original" definitions of "cc" and "first-denomination" are given below:
;;
(define (count-change amount)
  (cc amount 5))

(define (cc amount kinds-of-coins)
  (cond ((= amount 0) 1)
	((or (< amount 0) (= kinds-of-coins 0)) 0)
	(else
	 (+ (cc amount
		(- kinds-of-coins 1))
	    (cc (- amount 
		   (first-denomination kinds-of-coins))
		kinds-of-coins)))))

(define (first-denomination kinds-of-coins)
  (cond ((= kinds-of-coins 1) 1)
	((= kinds-of-coins 2) 5)
	((= kinds-of-coins 3) 10)
	((= kinds-of-coins 4) 25)
	((= kinds-of-coins 5) 50)))

;;
;; We will be re-defining these procedures below.
;;
;; Copying in the code from the problem statement:
;;
(define us-coins (list 50 25 10 5 1))
(define uk-coins (list 100 50 20 10 5 2 1 0.5))

(define (count-change-us amount)
  (cc amount us-coins))
(define (count-change-uk amount)
  (cc amount uk-coins))

(define (cc amount coin-values)
  (cond ((= amount 0) 1)
	((or (< amount 0) (no-more? coin-values)) 0)
	(else
	 (+ (cc amount
		(except-first-denomination coin-values))
	    (cc (- amount
		   (first-denomination coin-values))
		coin-values)))))

;;
;; Supplying the answers required to support the new computational model:
;;
(define (first-denomination coin-values)
  (car coin-values))

(define (except-first-denomination coin-values) 
  (cdr coin-values))

(define (no-more? coin-values)
  (null? coin-values))

;;
;; Let's run these results and see what we obtain:
;;
(cc 100 us-coins)
;; ==> 292
(cc 11 us-coins)
;; ==> 4

;;
;; Or, expressing it in terms of the procedures defined above:
;;
(count-change-us 100)
;; ==> 292
(count-change-us 11)
;; ==> 4

;;
;; These are the values we obtained using the old procedures from Section 1.2
;;

;;
;; The British system, having more denominations, gives a larger number for 
;; any given monetary value. For instance:
;;
(count-change-uk 11)
;; ==> 62

;;
;; Reversing the order of the coins in the list does not affect the value obtained:
;;
(define us-coins-reverse (reverse us-coins))
(define uk-coins-reverse (reverse uk-coins))

(cc 11 us-coins-reverse)
;; ==> 4
(cc 100 us-coins-reverse)
;; ==> 292
(cc 11 uk-coins-reverse)
;; ==> 62

(equal? (cc 11 us-coins) (cc 11 us-coins-reverse))
;; ==> #t
(equal? (cc 100 us-coins) (cc 100 us-coins-reverse))
;; ==> #t
(equal? (cc 11 uk-coins) (cc 11 uk-coins-reverse))
;; ==> #t

;;
;; This makes "logical" sense, since if we are counting the number of ways to divide up 
;; e.g., 11 cents using a bag of (50,25,10,5,1) denominations, the way in which the elements
;; of the bag are ordered should not make a difference.. i.e., it should not make a difference
;; whether I start counting with "1"s or with "50"s.. in either case, I should arrive at the 
;; same total number of countings given a set of elements in the bag.
;;

;;
;; If, for the sake of adventure, we wish to expand the respective call graphs (for "forward" and 
;; "reverse" ordering of the coins), we can do so as below. We will also "typedef" some of the 
;; procedure calls for the sake of clarity:
;;
(define n no-more?)
(define f first-denomination)
(define r except-first-denomination)

;;
;; First call graph:
;;
(cc 6 us-coins)
(cc 6 '(50 25 10 5 1))
(+ (cc 6 (r '(50 25 10 5 1))) (cc (- 6 (f '(50 25 10 5 1))) '(50 25 10 5 1)))
(+ (cc 6 '(25 10 5 1)) (cc (- 6 50) '(50 25 10 5 1)))
(+ (cc 6 '(25 10 5 1)) (cc -44 '(50 25 10 5 1)))
(+ (cc 6 '(25 10 5 1)) 0)
(cc 6 '(25 10 5 1))  ;; <== we can throw out half-dollars
(+ (cc 6 (r '(25 10 5 1))) (cc (- 6 (f '(25 10 5 1))) '(25 10 5 1)))
(+ (cc 6 '(10 5 1)) (cc (- 6 25) '(25 10 5 1)))
(+ (cc 6 '(10 5 1)) (cc -19 '(25 10 5 1)))
(+ (cc 6 '(10 5 1)) 0)
(cc 6 '(10 5 1))  ;; <== we can throw out half-dollars, quarters
(+ (cc 6 (r '(10 5 1))) (cc (- 6 (f '(10 5 1))) '(10 5 1)))
(+ (cc 6 '(5 1)) (cc (- 6 10) '(10 5 1)))
(+ (cc 6 '(5 1)) (cc -4 '(10 5 1)))
(+ (cc 6 '(5 1)) 0)
(cc 6 '(5 1))  ;; <== we can throw out half-dollars, quarters, dimes
(+ (cc 6 (r '(5 1))) (cc (- 6 (f '(5 1))) '(5 1)))
(+ (cc 6 '(1)) (cc 1 '(5 1))) ;; <== indicates that we can use either (a) all pennies, or (b) pennies and nickels
;;;;;;;;;;;;;;;;
(+ (+ (cc 6 (r '(1))) (cc (- 6 (f '(1))) '(1)))
   (+ (cc 1 (r '(5 1))) (cc (- 1 (f '(5 1))) '(5 1))))
;;;;;;;;;;;;;;;; 
(+ (+ (cc 6 '()) (cc (- 6 1) '(1)))
   (+ (cc 1 '(1)) (cc (- 1 5) '(5 1))))
;;;;;;;;;;;;;;;; 
(+ (+ 0 (cc 5 '(1)))
   (+ (cc 1 '(1)) (cc -4 '(5 1))))
;;;;;;;;;;;;;;;; 
(+ (cc 5 '(1)) (+ (cc 1 '(1)) 0))
(+ (cc 5 '(1)) (cc 1 '(1))) ;; <== count 5 cents, using pennies + count 1 cent, using pennies
(+ (cc 5 '(1)) (+ (cc 1 '()) (cc (- 1 (f '(1))) '(1))))
(+ (cc 5 '(1)) (+ 0 (cc (- 1 1) '(1))))
(+ (cc 5 '(1)) (cc 0 '(1)))
(+ (cc 5 '(1)) 1)
(+ (+ (cc 5 (r '(1))) (cc (- 5 (f '(1))) '(1))) 1)
(+ (+ (cc 5 '()) (cc (- 5 1) '(1))) 1)
(+ (+ 0 (cc 4 '(1))) 1)
(+ (cc 4 '(1)) 1)
(+ (+ (cc 4 (r '(1))) (cc (- 4 (f '(1))) '(1))) 1)
(+ (+ (cc 4 '()) (cc (- 4 1) '(1))) 1)
(+ (+ 0 (cc 3 '(1))) 1)
(+ (cc 3 '(1)) 1)
(+ (+ (cc 3 (r '(1))) (cc (- 3 (f '(1))) '(1))) 1)
(+ (+ (cc 3 '()) (cc (- 3 1) '(1))) 1)
(+ (+ 0 (cc 2 '(1))) 1)
(+ (cc 2 '(1)) 1)
(+ (+ (cc 2 (r '(1))) (cc (- 2 (f '(1))) '(1))) 1)
(+ (+ (cc 2 '()) (cc (- 2 1) '(1))) 1)
(+ (+ 0 (cc 1 '(1))) 1)
(+ (cc 1 '(1)) 1)
(+ (+ (cc 1 (r '(1))) (cc (- 1 (f '(1))) '(1))) 1)
(+ (+ (cc 1 '()) (cc (- 1 1) '(1))) 1)
(+ (+ 0 (cc 0 '(1))) 1)
(+ (cc 0 '(1)) 1)
(+ 1 1)
2

;;
;; Second call graph:
;;
(cc 6 us-coins-reverse)
(cc 6 '(1 5 10 25 50))
(+ (cc 6 (r '(1 5 10 25 50))) (cc (- 6 (f '(1 5 10 25 50))) '(1 5 10 25 50)))
(+ (cc 6 '(5 10 25 50)) (cc (- 6 1) '(1 5 10 25 50)))
(+ (cc 6 '(5 10 25 50)) (cc 5 '(1 5 10 25 50)))
;;;;;;;;
(+ (+ (cc 6 (r '(5 10 25 50))) (cc (- 6 (f '(5 10 25 50))) '(5 10 25 50)))
   (+ (cc 5 (r '(1 5 10 25 50))) (cc (- 5 (f '(1 5 10 25 50))) '(1 5 10 25 50))))
;;;;;;;; 
(+ (+ (cc 6 '(10 25 50)) (cc (- 6 5) '(5 10 25 50)))
   (+ (cc 5 '(5 10 25 50)) (cc (- 5 1) '(1 5 10 25 50))))
;;;;;;;; 
(+ (+ (cc 6 '(10 25 50)) (cc 1 '(5 10 25 50)))
   (+ (cc 5 '(5 10 25 50)) (cc 4 '(1 5 10 25 50))))
;;;;;;;; 
(+ (+ (+ (cc 6 (r '(10 25 50))) (cc (- 6 (f '(10 25 50))) '(10 25 50)))
      (+ (cc 1 (r '(5 10 25 50))) (cc (- 1 (f '(5 10 25 50))) '(5 10 25 50))))
   (+ (+ (cc 5 (r '(5 10 25 50))) (cc (- 5 (f '(5 10 25 50)) '(5 10 25 50))))
      (+ (cc 4 (r '(1 5 10 25 50))) (cc (- 4 (f '(1 5 10 25 50))) '(1 5 10 25 50)))))
;;;;;;;; 
(+ (+ (+ (cc 6 '(25 50)) (cc (- 6 10) '(10 25 50)))
      (+ (cc 1 '(10 25 50)) (cc (- 1 5) '(5 10 25 50))))
   (+ (+ (cc 5 '(10 25 50)) (cc (- 5 5) '(5 10 25 50)))
      (+ (cc 4 '(5 10 25 50)) (cc (- 4 1) '(1 5 10 25 50)))))
;;;;;;;; 
(+ (+ (+ (cc 6 '(25 50)) (cc -4 '(10 25 50)))
      (+ (cc 1 '(10 25 50)) (cc -4 '(5 10 25 50))))
   (+ (+ (cc 5 '(10 25 50)) (cc 0 '(5 10 25 50)))
      (+ (cc 4 '(5 10 25 50)) (cc 3 '(1 5 10 25 50)))))
;;;;;;;; 
(+ (+ (+ (cc 6 '(25 50)) 0)
      (+ (cc 1 '(10 25 50)) 0))
   (+ (+ (cc 5 '(10 25 50)) 1)
      (+ (cc 4 '(5 10 25 50)) (cc 3 '(1 5 10 25 50)))))
;;;;;;;; 
(+ (+ (cc 6 '(25 50))
      (cc 1 '(10 25 50)))
   (+ (+ (cc 5 '(10 25 50)) 1)
      (+ (cc 4 '(5 10 25 50)) (cc 3 '(1 5 10 25 50)))))
;;;;;;;; 
(+ (+ (+ (cc 6 (r '(25 50))) (cc (- 6 (f '(25 50))) '(25 50)))
      (+ (cc 1 (r '(10 25 50))) (cc (- 1 (f '(10 25 50))) '(10 25 50))))
   (+ (+ (+ (cc 5 (r '(10 25 50))) (cc (- 5 (f '(10 25 50))) '(10 25 50))) 1)
      (+ (+ (cc 4 (r '(5 10 25 50))) (cc (- 4 (f '(5 10 25 50))) '(5 10 25 50)))
	 (+ (cc 3 (r '(1 5 10 25 50))) (cc (- 3 (f '(1 5 10 25 50))) '(1 5 10 25 50))))))
;;;;;;;;
(+ (+ (+ (cc 6 '(50)) (cc (- 6 25) '(25 50)))
      (+ (cc 1 '(25 50)) (cc (- 1 10) '(10 25 50))))
   (+ (+ (+ (cc 5 '(25 50)) (cc (- 5 10) '(10 25 50))) 1)
      (+ (+ (cc 4 '(10 25 50)) (cc (- 4 5) '(5 10 25 50)))
	 (+ (cc 3 '(5 10 25 50)) (cc (- 3 1) '(1 5 10 25 50))))))
;;;;;;;; 
(+ (+ (+ (cc 6 '(50)) (cc -19 '(25 50)))
      (+ (cc 1 '(25 50)) (cc -9 '(10 25 50))))
   (+ (+ (+ (cc 5 '(25 50)) (cc -5 '(10 25 50))) 1)
      (+ (+ (cc 4 '(10 25 50)) (cc -1 '(5 10 25 50)))
	 (+ (cc 3 '(5 10 25 50)) (cc 2 '(1 5 10 25 50))))))
;;;;;;;; 
(+ (+ (+ (cc 6 '(50)) 0)
      (+ (cc 1 '(25 50)) 0))
   (+ (+ (+ (cc 5 '(25 50)) 0) 1)
      (+ (+ (cc 4 '(10 25 50)) 0)
	 (+ (cc 3 '(5 10 25 50)) (cc 2 '(1 5 10 25 50))))))
;;;;;;;; 
(+ (+ (cc 6 '(50))
      (cc 1 '(25 50)))
   (+ (+ (cc 5 '(25 50)) 1)
      (+ (cc 4 '(10 25 50))
	 (+ (cc 3 '(5 10 25 50)) (cc 2 '(1 5 10 25 50))))))
;;;;;;;;; 
(+ (+ (+ (cc 6 (r '(50))) (cc (- 6 (f '(50))) '(50)))
      (+ (cc 1 (r '(25 50))) (cc (- 1 (f '(25 50))) '(25 50))))
   (+ (+ (+ (cc 5 (r '(25 50))) (cc (- 5 (f '(25 50))) '(25 50))) 1)
      (+ (+ (cc 4 (r '(10 25 50))) (cc (- 4 (f '(10 25 50))) '(10 25 50)))
	 (+ (+ (cc 3 (r '(5 10 25 50))) (cc (- 3 (f '(5 10 25 50))) '(5 10 25 50)))
	    (+ (cc 2 (r '(1 5 10 25 50))) (cc (- 2 (f '(1 5 10 25 50))) '(1 5 10 25 50)))))))
;;;;;;;;;; 
(+ (+ (+ (cc 6 '()) (cc (- 6 50) '(50)))
      (+ (cc 1 '(50)) (cc (- 1 25) '(25 50))))
   (+ (+ (+ (cc 5 '(50)) (cc (- 5 25) '(25 50))) 1)
      (+ (+ (cc 4 '(25 50)) (cc (- 4 10) '(10 25 50)))
	 (+ (+ (cc 3 '(10 25 50)) (cc (- 3 5) '(5 10 25 50)))
	    (+ (cc 2 '(5 10 25 50)) (cc (- 2 1) '(1 5 10 25 50)))))))
;;;;;;;;;;
(+ (+ (+ 0 (cc -44 '(50)))
      (+ (cc 1 '(50)) (cc -24 '(25 50))))
   (+ (+ (+ (cc 5 '(50)) (cc -20 '(25 50))) 1)
      (+ (+ (cc 4 '(25 50)) (cc -6 '(10 25 50)))
	 (+ (+ (cc 3 '(10 25 50)) (cc -2 '(5 10 25 50)))
	    (+ (cc 2 '(5 10 25 50)) (cc 1 '(1 5 10 25 50)))))))
;;;;;;;;;; 
(+ (+ (+ 0 0)
      (+ (cc 1 '(50)) 0))
   (+ (+ (+ (cc 5 '(50)) 0) 1)
      (+ (+ (cc 4 '(25 50)) 0)
	 (+ (+ (cc 3 '(10 25 50)) 0)
	    (+ (cc 2 '(5 10 25 50)) (cc 1 '(1 5 10 25 50)))))))
;;;;;;;;;; 
(+ (+ 0
      (cc 1 '(50)))
   (+ (+ (cc 5 '(50)) 1)
      (+ (cc 4 '(25 50))
	 (+ (cc 3 '(10 25 50))
	    (+ (cc 2 '(5 10 25 50)) (cc 1 '(1 5 10 25 50)))))))
;;;;;;;;;; 
(+ (cc 1 '(50))
   (+ (+ (cc 5 '(50)) 1)
      (+ (cc 4 '(25 50))
	 (+ (cc 3 '(10 25 50))
	    (+ (cc 2 '(5 10 25 50)) (cc 1 '(1 5 10 25 50)))))))
;;;;;;;;;; 
(+ (+ (cc 1 (r '(50))) (cc (- 1 (f '(50))) '(50)))
   (+ (+ (+ (cc 5 (r '(50))) (cc (- 5 (f '(50))) '(50))) 1)
      (+ (+ (cc 4 (r '(25 50))) (cc (- 4 (f '(25 50))) '(25 50)))
	 (+ (+ (cc 3 (r '(10 25 50))) (cc (- 3 (f '(10 25 50))) '(10 25 50)))
	    (+ (+ (cc 2 (r '(5 10 25 50))) (cc (- 2 (f '(5 10 25 50))) '(5 10 25 50)))
	       (+ (cc 1 (r '(1 5 10 25 50))) (cc (- 1 (f '(1 5 10 25 50))) '(1 5 10 25 50))))))))
;;;;;;;;;; 
(+ (+ (cc 1 '()) (cc (- 1 50) '(50)))
   (+ (+ (+ (cc 5 '()) (cc (- 5 50) '(50))) 1)
      (+ (+ (cc 4 '(50)) (cc (- 4 25) '(25 50)))
	 (+ (+ (cc 3 '(25 50)) (cc (- 3 10) '(10 25 50)))
	    (+ (+ (cc 2 '(10 25 50)) (cc (- 2 5) '(5 10 25 50)))
	       (+ (cc 1 '(5 10 25 50)) (cc (- 1 1) '(1 5 10 25 50))))))))
;;;;;;;;;; 
(+ (+ 0 (cc -49 '(50)))
   (+ (+ (+ 0 (cc -45 '(50))) 1)
      (+ (+ (cc 4 '(50)) (cc -21 '(25 50)))
	 (+ (+ (cc 3 '(25 50)) (cc -7 '(10 25 50)))
	    (+ (+ (cc 2 '(10 25 50)) (cc -3 '(5 10 25 50)))
	       (+ (cc 1 '(5 10 25 50)) (cc 0 '(1 5 10 25 50))))))))
;;;;;;;;; 
(+ (+ 0 0)
   (+ (+ (+ 0 0) 1)
      (+ (+ (cc 4 '(50)) 0)
	 (+ (+ (cc 3 '(25 50)) 0)
	    (+ (+ (cc 2 '(10 25 50)) 0)
	       (+ (cc 1 '(5 10 25 50)) 1))))))
;;;;;;;;; 
(+ 0
   (+ (+ 0 1)
      (+ (cc 4 '(50))
	 (+ (cc 3 '(25 50))
	    (+ (cc 2 '(10 25 50))
	       (+ (cc 1 '(5 10 25 50)) 1))))))
;;;;;;;;; 
(+ (+ 0 1)
   (+ (cc 4 '(50))
      (+ (cc 3 '(25 50))
	 (+ (cc 2 '(10 25 50))
	    (+ (cc 1 '(5 10 25 50)) 1)))))
;;;;;;;;;; 
(+ 1
   (+ (cc 4 '(50))
      (+ (cc 3 '(25 50))
	 (+ (cc 2 '(10 25 50))
	    (+ (cc 1 '(5 10 25 50)) 1)))))
;;;;;;;;; 
(+ 1
   (+ (+ (cc 4 (r '(50))) (cc (- 4 (f '(50))) '(50)))
      (+ (+ (cc 3 (r '(25 50))) (cc (- 3 (f '(25 50))) '(25 50)))
	 (+ (+ (cc 2 (r '(10 25 50))) (cc (- 2 (f '(10 25 50))) '(10 25 50)))
	    (+ (+ (cc 1 (r ('5 10 25 50))) (cc (- 1 (f '(5 10 25 50))) '(5 10 25 50))) 1)))))
;;;;;;;;;; 
(+ 1
   (+ (+ (cc 4 '()) (cc (- 4 50) '(50)))
      (+ (+ (cc 3 '(50)) (cc (- 3 25) '(25 50)))
	 (+ (+ (cc 2 '(25 50)) (cc (- 2 10) '(10 25 50)))
	    (+ (+ (cc 1 '(10 25 50)) (cc (- 1 5) '(5 10 25 50))) 1)))))
;;;;;;;;;;; 
(+ 1
   (+ (+ 0 (cc -46 '(50)))
      (+ (+ (cc 3 '(50)) (cc -22 '(25 50)))
	 (+ (+ (cc 2 '(25 50)) (cc -8 '(10 25 50)))
	    (+ (+ (cc 1 '(10 25 50)) (cc -4  '(5 10 25 50))) 1)))))
;;;;;;;;;;; 
(+ 1
   (+ (+ 0 0)
      (+ (+ (cc 3 '(50)) 0)
	 (+ (+ (cc 2 '(25 50)) 0)
	    (+ (+ (cc 1 '(10 25 50)) 0) 1)))))
;;;;;;;;;;;; 
(+ 1 
   (+ 0
      (+ (cc 3 '(50))
	 (+ (cc 2 '(25 50))
	    (+ (cc 1 '(10 25 50)) 1)))))
;;;;;;;;;;;; 
(+ 1
   (+ (cc 3 '(50))
      (+ (cc 2 '(25 50))
	 (+ (cc 1 '(10 25 50)) 1))))
;;;;;;;;;;;; 
(+ 1 
   (+ (+ (cc 3 (r '(50))) (cc (- 3 (f '(50))) '(50)))
      (+ (+ (cc 2 (r '(25 50))) (cc (- 2 (f '(25 50))) '(25 50)))
	 (+ (+ (cc 1 (r '(10 25 50))) (cc (- 1 (f '(10 25 50))) '(10 25 50))) 1))))
;;;;;;;;;;;; 
(+ 1
   (+ (+ (cc 3 '()) (cc (- 3 50) '(50)))
      (+ (+ (cc 2 '(50)) (cc (- 2 25) '(25 50)))
	 (+ (+ (cc 1 '(25 50)) (cc (- 1 10) '(10 25 50))) 1))))
;;;;;;;;;;;; 
(+ 1
   (+ (+ 0 (cc -37 '(50)))
      (+ (+ (cc 2 '(50)) (cc -23 '(25 50)))
	 (+ (+ (cc 1 '(25 50)) (cc -9 '(10 25 50))) 1))))
;;;;;;;;;;;; 
(+ 1
   (+ (+ 0 0)
      (+ (+ (cc 2 '(50)) (cc -23 '(25 50)))
	 (+ (+ (cc 1 '(25 50)) 0) 1))))
;;;;;;;;;;;; 
(+ 1
   (+ 0
      (+ (+ (cc 2 '(50)) 0)
	 (+ (cc 1 '(25 50)) 1))))
;;;;;;;;;;;; 
(+ 1 
   (+ (cc 2 '(50))
      (+ (cc 1 '(25 50)) 1)))
;;;;;;;;;;;; 
(+ 1
   (+ (+ (cc 2 (r '(50))) (cc (- 2 (f '(50))) '(50)))
      (+ (+ (cc 1 (r '(25 50))) (cc (- 1 (f '(25 50))) '(25 50))) 1)))
;;;;;;;;;;;; 
(+ 1 
   (+ (+ (cc 2 '()) (cc (- 2 50) '(50)))
      (+ (+ (cc 1 '(50)) (cc (- 1 25) '(25 50))) 1)))
;;;;;;;;;;;; 
(+ 1 
   (+ (+ 0 (cc -48 '(50)))
      (+ (+ (cc 1 '(50)) (cc -24 '(25 50))) 1)))
;;;;;;;;;;;; 
(+ 1
   (+ (+ 0 0)
      (+ (+ (cc 1 '(50)) 0) 1)))
;;;;;;;;;;;; 
(+ 1
   (+ 0
      (+ (cc 1 '(50)) 1)))
;;;;;;;;;;;; 
(+ 1 (+ (cc 1 '(50)) 1))
(+ 1 (+ (+ (cc 1 (r '(50))) (cc (- 1 (f '(50))) '(50))) 1))
(+ 1 (+ (+ (cc 1 '()) (cc (- 1 50) '(50))) 1))
(+ 1 (+ (+ 0 (cc -49 '(50))) 1))
(+ 1 (+ (+ 0 0) 1))
(+ 1 (+ 0 1))
(+ 1 1)
2