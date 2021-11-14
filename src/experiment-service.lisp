(defpackage ab-testing/experiment-service
  (:use #:cl
        #:mito
        #:sxql)
  (:import-from #:ab-testing/models/variant
                #:variant
                #:variant-weight
                #:variants-by-experiment
                #:find-variant)
  (:import-from #:ab-testing/models/experiment
                #:experiment
                #:update-plan
                #:next-variant-id))
(in-package #:ab-testing/experiment-service)

(defun calculate-plan! (experiment)
  (let* ((variants (variants-by-experiment experiment))
         (id-weight-pair (mapcar #'(lambda (variant)
                                     (cons (object-id variant) (variant-weight variant)))
                                 variants))
         (gcd-of-values (apply #'gcd (mapcar #'cdr id-weight-pair))))
    (flet ((populate-plan (acc el)
             (let ((list-size (/ (cdr el) gcd-of-values)))
               (append (make-list list-size :initial-element (car el)) acc))))
      (let ((plan (reduce #'populate-plan id-weight-pair :initial-value (list))))
        (update-plan experiment plan)))))

(defun next-variant (experiment)
  (find-variant (next-variant-id experiment (random 100 (make-random-state t)))))
