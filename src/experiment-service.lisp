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
                #:all-experiments
                #:update-plan
                #:next-variant-id)
  (:import-from #:ab-testing/models/subject
                #:create-subject)
  (:local-nicknames (#:subject #:ab-testing/models/subject))
  (:export #:subjects-for))
(in-package #:ab-testing/experiment-service)

(defun calculate-plan! (experiment)
  (let* ((variants (variants-by-experiment experiment))
         (id-weight-pair (mapcar #'(lambda (variant)
                                     (cons (object-id variant) (variant-weight variant)))
                                 variants)))
    (flet ((populate-plan (acc el)
             (let* ((gcd-of-values (apply #'gcd (mapcar #'cdr id-weight-pair)))
                    (list-size (/ (cdr el) gcd-of-values)))
               (append (make-list list-size :initial-element (car el)) acc))))

      (let ((plan (reduce #'populate-plan id-weight-pair :initial-value (list))))
        (update-plan experiment plan)))))

(defun next-variant (experiment)
  (find-variant (next-variant-id experiment (random 100 (make-random-state t)))))

(defun subjects-for (device-id)
  (let ((subjects (subject:find-by-device-id device-id)))
    (if subjects
        subjects
        (let ((experiments (all-experiments)))
          (mapcar #'(lambda (experiment)
                      (create-subject device-id experiment (next-variant experiment)))
                  experiments)))))
