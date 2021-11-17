(defpackage ab-testing/experiment-service
  (:use #:cl
        #:mito
        #:sxql)
  (:import-from #:ab-testing/models/variant
                #:variant
                #:variant-weight
                #:variant-payload
                #:find-variant)
  (:import-from #:ab-testing/models/experiment
                #:experiment
                #:update-plan
                #:next-variant-id
                #:experiment-name)
  (:import-from #:ab-testing/models/subject
                #:create-subject)
  (:local-nicknames (#:subject #:ab-testing/models/subject)
                    (#:experiment #:ab-testing/models/experiment)
                    (#:variant #:ab-testing/models/variant))
  (:export #:subjects-for
           #:statistic))
(in-package #:ab-testing/experiment-service)

(defun calculate-plan! (experiment)
  (let* ((variants (variant:by-experiment experiment))
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
        (let ((experiments (experiment:all)))
          (mapcar #'(lambda (experiment)
                      (create-subject device-id experiment (next-variant experiment)))
                  experiments)))))

(defun statistic ()
  (flet ((variants-list (experiment)
           (mapcar #'(lambda (variant)
                       (list :name (variant-payload variant)
                             :devices-count (subject:count-by :key :variant :value variant)))
                   (variant:by-experiment experiment))))

    (list :devices-count (subject:count-by)
          :experiments
          (mapcar #'(lambda (experiment)
                      (list :name (experiment-name experiment)
                            :devices-count (subject:count-by :key :experiment :value experiment)
                            :variants (variants-list experiment)))
                  (experiment:all)))))
