;;
;; Exercise 2.79
;;
;; Define a generic equality predicate equ? that tests the equality of two numbers, and 
;; install it in the generic arithmetic package. This operation should work for ordinary 
;; numbers, rational numbers, and complex numbers.
;;

;; =================
;; Generic Procedure
;; =================
(define (equ? x y) (apply-generic 'equ? x y))

;; New scheme number package:
(define (install-scheme-number-package)
  (define (tag x)
    (attach-tag 'scheme-number x))
  (put 'add '(scheme-number scheme-number)
    (lambda (x y) (tag (+ x y))))
  (put 'sub '(scheme-number scheme-number)
    (lambda (x y) (tag (- x y))))
  (put 'mul '(scheme-number scheme-number)
    (lambda (x y) (tag (* x y))))
  (put 'div '(scheme-number scheme-number)
    (lambda (x y) (tag (/ x y))))
  
  ;; =============
  ;; New Procedure
  ;; ============= 
  (put 'equ? '(scheme-number scheme-number)
       (lambda (x y) (= x y)))
  
  (put 'make 'scheme-number
       (lambda (x) (tag x)))
  'done) 

;; New rational package:
(define (install-rational-package)
  ;; internal procedures
  (define (numer x) (car x))
  (define (denom x) (cdr x))
  (define (make-rat n d)
    (let ((g (gcd n d)))
      (cons (/ n g) (/ d g))))
  (define (add-rat x y)
    (make-rat (+ (* (numer x) (denom y))
		  (* (numer y) (denom x)))
	            (* (denom x) (denom y))))
  (define (sub-rat x y)
    (make-rat (- (* (numer x) (denom y))
		  (* (numer y) (denom x)))
	            (* (denom x) (denom y))))
  (define (mul-rat x y)
    (make-rat (* (numer x) (numer y))
	            (* (denom x) (denom y))))
  (define (div-rat x y)
    (make-rat (* (numer x) (denom y))
	            (* (denom x) (numer y))))

  ;; interface to rest of the system
  (define (tag x) (attach-tag 'rational x))
  (put 'add '(rational rational)
       (lambda (x y) (tag (add-rat x y))))
  (put 'sub '(rational rational)
       (lambda (x y) (tag (sub-rat x y))))
  (put 'mul '(rational rational)
       (lambda (x y) (tag (mul-rat x y))))
  (put 'div '(rational rational)
       (lambda (x y) (tag (div-rat x y))))

  ;; ============= 
  ;; New Procedure
  ;; ============= 
  (put 'equ? '(rational rational)
       (lambda (x y)
	 (and (= (numer x) (numer y))
	      (= (denom x) (denom y)))))

  (put 'make 'rational
       (lambda (n d) (tag (make-rat n d))))
  'done)

;;
;; For the complex package, we can check equality by making 
;; sure the "real" and "imag" parts of the complex number are 
;; equivalent, and we can "intercept" this check at the top
;; level of complex (i.e., no need to update the particular 
;; polar and rectangular sub-packages). 
;;
;; Note that we will want to unit-test for the equivalency
;; of complex numbers which are rotated through 2*pi.
;;
(define (install-complex-package)
  ;; constructors
  (define (make-from-real-imag x y)
    ((get 'make-from-real-imag 'rectangular) x y))
  (define (make-from-mag-ang r a)
    ((get 'make-from-mag-ang 'polar) r a))

  ;; internal procedures
  (define (add-complex z1 z2)
    (make-from-real-imag (+ (real-part z1) (real-part z2))
			  (+ (imag-part z1) (imag-part z2))))
  (define (sub-complex z1 z2)
    (make-from-real-imag (- (real-part z1) (real-part z2))
			  (- (imag-part z1) (imag-part z2))))
  (define (mul-complex z1 z2)
    (make-from-mag-ang (* (magnitude z1) (magnitude z2))
		              (+ (angle z1) (angle z2))))
  (define (div-complex z1 z2)
    (make-from-mag-ang (/ (magnitude z1) (magnitude z2))
		              (- (angle z1) (angle z2))))

  ;; interface to rest of the system
  (define (tag z) (attach-tag 'complex z))
  (put 'add '(complex complex)
       (lambda (z1 z2) (tag (add-complex z1 z2))))
  (put 'sub '(complex complex)
       (lambda (z1 z2) (tag (sub-complex z1 z2))))
  (put 'mul '(complex complex)
       (lambda (z1 z2) (tag (mul-complex z1 z2))))
  (put 'div '(complex complex)
       (lambda (z1 z2) (tag (div-complex z1 z2))))
  
  ;; ============= 
  ;; New Procedure
  ;; =============
  ;; Rather than strict equality, we test for "exactness" within a 
  ;; prescribed tolerance, since we want to allow that complex numbers
  ;; that are congruent up to within a rotation through 2*PI are 
  ;; equivalent, and without allowing for such a tolerance window, such
  ;; numbers would otherwise evaluate to "not equ?".
  (put 'equ? '(complex complex)
       (lambda (x y)
	 (define (diff a b) (abs (- a b)))
	 (let ((tolerance 0.0000001))
	   (and (< (diff (real-part x) (real-part y)) tolerance)
		(< (diff (imag-part x) (imag-part y)) tolerance)))))

  (put 'make-from-real-imag 'complex
       (lambda (x y) (tag (make-from-real-imag x y))))
  (put 'make-from-mag-ang 'complex
       (lambda (r a) (tag (make-from-mag-ang r a))))

  (put 'real-part '(complex) real-part)
  (put 'imag-part '(complex) imag-part)
  (put 'magnitude '(complex) magnitude)
  (put 'angle '(complex) angle)

  'done)

;;
;; Reinstall the number packages:
;;
(install-scheme-number-package)
(install-rational-package)
(install-complex-package)

;;
;; Used to check that rotations through 2*PI are equivalent.
;;
(define PI 3.141592653589793238462643383279)

;;
;; Test the regular scheme numbers:
;;
(equ? (make-scheme-number 1) (make-scheme-number 1))
;; ==> #t 
(equ? (make-scheme-number 5) (make-scheme-number 5))
;; ==> #t
(equ? (make-scheme-number 0) (make-scheme-number 0))
;; ==> #t
(equ? (make-scheme-number -1) (make-scheme-number -1))
;; ==> #t

(equ? (make-scheme-number 5) (make-scheme-number 10))
;; ==> #f

;;
;; Test the rational numbers:
;;
(equ? (make-rational 1 2) (make-rational 1 2))
;; ==> #t
(equ? (make-rational 1 2) (make-rational 2 4))
;; ==> #t
(equ? (make-rational 1 2) (make-rational 3 4))
;; ==> #f

;;
;; Test the complex numbers:
;;
(equ? (make-complex-from-real-imag 1 2) (make-complex-from-real-imag 1 2))
;; ==> #t
(equ? (make-complex-from-real-imag 1 2) (make-complex-from-real-imag 1 3))
;; ==> #f

(equ? (make-complex-from-mag-ang 1 2) (make-complex-from-mag-ang 1 2))
;; ==> #t
(equ? (make-complex-from-mag-ang 1 2) (make-complex-from-mag-ang 1 3))
;; ==> #f
(equ? (make-complex-from-mag-ang 1 2) (make-complex-from-mag-ang 1 (+ 2 (* 2 PI))))
;; ==> #t