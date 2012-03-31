(load "prisoner.scm")

;; ++++++++++++++++++++++++++++++++++++++++++++++++++ 
;; Problem 1
;; 
;; Definition of "extract-entry"
;; ++++++++++++++++++++++++++++++++++++++++++++++++++ 

;;
;; The *game-association-list* is defined as follows:
;;
(define *game-association-list*
  (list (list (list "c" "c") (list 3 3))
	(list (list "c" "d") (list 0 5))
	(list (list "d" "c") (list 5 0))
	(list (list "d" "d") (list 1 1))))

;;
;; We can extract a specific entry in this list by using the "list-ref" procedure. 
;;
;; For example:
;;
(list-ref *game-association-list* 0)
;; ==> (("c" "c") (3 3))
(list-ref *game-association-list* 1)
;; ==> (("c" "d") (0 5))

;;
;; and so on. To extract the entry associated with a specific play, we need to extract 
;; the "car" of the entry, and make sure that both elements of this "car" correspond 
;; to both elements of the argument play. 
;;
;; We define our "extract-entry" procedure as follows:
;;
(define (extract-entry play *game-association-list*)
  ;; 
  ;; Returns "true" if the play matches the entry:
  ;;
  (define (compare play entry)
    (let ((test (car entry)))
      (and (string=? (car play) (car test))
	   (string=? (cadr play) (cadr test)))))

  (let
      ;; 
      ;; Get references to each entry in the *game-association-list*:
      ;;
      ((first (list-ref *game-association-list* 0))
       (second (list-ref *game-association-list* 1))
       (third (list-ref *game-association-list* 2))
       (fourth (list-ref *game-association-list* 3)))
   
    ;; 
    ;; If we find a match, return that specific entry:
    ;;
    (cond 
     ((compare play first) first)
     ((compare play second) second)
     ((compare play third) third)
     ((compare play fourth) fourth)
     (else '()))))

;;
;; We can test our procedure as follows:
;;
(extract-entry (make-play "c" "c") *game-association-list*)
;; ==> (("c" "c") (3 3))
(extract-entry (make-play "c" "d") *game-association-list*)
;; ==> (("c" "d") (0 5))
(extract-entry (make-play "d" "c") *game-association-list*)
;; ==> (("d" "c") (5 0))
(extract-entry (make-play "d" "d") *game-association-list*)
;; ==> (("d" "d") (1 1))
(extract-entry (make-play "x" "x") *game-association-list*)
;; ==> ()

;;
;; Similarly, since "get-point-list" is defined as:
;;
(define (get-point-list game)
  (cadr (extract-entry game *game-association-list*)))

(get-point-list (make-play "c" "c"))
;; ==> (3 3)
(get-point-list (make-play "c" "d"))
;; ==> (0 5)
(get-point-list (make-play "d" "c"))
;; ==> (5 0)
(get-point-list (make-play "d" "d"))
;; ==> (1 1)

;; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
;; Problem 2
;;
;; Use "play-loop" to play games between the five strategies.
;; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

;;
;; For reference, the five strategies are defined as:
;;
(define (NASTY my-history other-history)
  "d")

(define (PATSY my-history other-history)
  "c")

(define (SPASTIC my-history other-history)
  (if (= (random 2) 0)
      "c"
      "d"))

(define (EGALITARIAN my-history other-history)
  (define (count-instances-of test hist)
    (cond ((empty-history? hist) 0)
	  ((string=? (most-recent-play hist) test)
	   (+ (count-instances-of test (rest-of-plays hist)) 1))
	  (else
	    (count-instances-of test (rest-of-plays hist)))))
  (let ((ds (count-instances-of "d" other-history))
	(cs (count-instances-of "c" other-history)))
    (if (> ds cs) "d" "c")))

(define (EYE-FOR-EYE my-history other-history)
  (if (empty-history? my-history)
      "c"
      (most-recent-play other-history)))
       
;;
;; NASTY is a highly "dominant" strategy. It never "loses" outright, at worst tying only 
;; when it plays against itself. Otherwise, NASTY is able to beat all the other strategies.
;;
;; When NASTY plays against the following opponents, we obtain the following results:
;;

;;
;;           -------------------------------------------------------------------------------------------------------------------------------
;;           |        NASTY         |         PATSY        |          SPASTIC          |       EGALITARIAN       |       EYE-FOR-EYE       |
;;------------------------------------------------------------------------------------------------------------------------------------------ 
;;   NASTY   | Ties with 1.0 points | Wins with 5.0 points | Wins with 3.030532 points | Wins with 1.0408 points | Wins with 1.0430 points | 
;;------------------------------------------------------------------------------------------------------------------------------------------
;; 

;;
;; PATSY never wins, and it loses badly against NASTY and SPASTIC. However, it ties with
;; itself, EGALITARIAN and EYE-FOR-EYE.
;;
;; When PATSY plays against the following opponents, we obtain the following results:
;;

;;
;;           ------------------------------------------------------------------------------------------------------------------------ 
;;           |         NASTY         |         PATSY        |         SPASTIC         |      EGALITARIAN     |      EYE-FOR-EYE     |
;;----------------------------------------------------------------------------------------------------------------------------------- 
;;   PATSY   | Loses with 0.0 points | Ties with 3.0 points | Loses with 1.588 points | Ties with 3.0 points | Ties with 3.0 points |
;;----------------------------------------------------------------------------------------------------------------------------------- 
;;

;;
;; Despite being ostensibly "random", the SPASTIC strategy fares quite well. When playing
;; against itself, the results are (essentially) a draw, where it wins or loses by a slight
;; random margin. Similarly, the results against EYE-FOR-EYE are usually nuetral, with a 
;; slight bias towards winning on the side of SPASTIC. However, it wins decisively against
;; PATSY and EGALITARIAN. It only loses against NASTY.
;;
;; When SPASTIC plays against the following opponents, we obtain the following results:
;;

;;
;;           ------------------------------------------------------------------------------------------------------------------------------ 
;;           |          NASTY          |        PATSY         |         SPASTIC          |       EGALITARIAN      |      EYE-FOR-EYE      |
;;----------------------------------------------------------------------------------------------------------------------------------------- 
;;  SPASTIC  | Loses with 0.529 points | Wins with 4.3 points | "Wins" with 2.239 points | Wins with 2.766 points | Wins with 2.30 points |
;;----------------------------------------------------------------------------------------------------------------------------------------- 
;;