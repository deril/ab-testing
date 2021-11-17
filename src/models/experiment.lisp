(defpackage ab-testing/models/experiment
  (:use #:cl
        #:mito)
  (:export #:experiment
           #:experiment-name
           #:update-plan
           #:next-variant-id
           #:all))
(in-package :ab-testing/models/experiment)

(deftable experiment ()
  ((name :col-type :text)
   (plan :col-type :text
         :deflate #'write-to-string
         :inflate #'read-from-string)))

(defun update-plan (experiment plan)
  (setf (slot-value experiment 'plan) plan)
  (save-dao experiment))

(defun next-variant-id (experiment seed)
  (let ((plan (experiment-plan experiment)))
    (nth (mod seed (length plan)) plan)))

(defun all ()
  (select-dao 'experiment))
