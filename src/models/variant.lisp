(defpackage ab-testing/models/variant
  (:use #:cl
        #:mito
        #:sxql)
  (:import-from #:ab-testing/models/experiment
                #:experiment)
  (:export #:variant
           #:variant-weight
           #:variant-payload
           #:variants-by-experiment
           #:find-variant))
(in-package :ab-testing/models/variant)

(deftable variant ()
  ((weight :col-type :integer)
   (payload :col-type :text)
   (experiment :col-type experiment)))

(defun variants-by-experiment (experiment)
  (select-dao 'variant (where (:= :experiment experiment))))

(defun find-variant (id)
  (find-dao 'variant :id id))
