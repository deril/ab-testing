(defpackage ab-testing/models/subject
  (:use #:cl
        #:mito
        #:sxql)
  (:import-from #:datafly)
  (:import-from #:ab-testing/models/variant
                #:variant
                #:variant-payload)
  (:import-from #:ab-testing/models/experiment
                #:experiment
                #:experiment-name)
  (:export #:subject
           #:find-by-device-id
           #:create-subject
           #:count-by
           #:name
           #:value))
(in-package :ab-testing/models/subject)

(deftable subject ()
  ((device-id :col-type :text)
   (variant :col-type variant)
   (experiment :col-type experiment)))

(defun find-by-device-id (device-id)
  (select-dao 'subject (where (:= :device-id device-id))))

(defun create-subject (device-id experiment variant)
  (create-dao 'subject
              :device-id device-id
              :experiment experiment
              :variant variant))

(defun count-by (&key key value)
  (case key
    (:variant (count-dao 'subject :variant value))
    (:experiment (count-dao 'subject :experiment value))
    (otherwise
     (let ((sql (select ((:as (:count (:distinct :device_id)) :count)) (from :subject))))
       (getf (first
              (retrieve-by-sql sql))
             :count)))))

(defmethod name ((subject subject))
  (experiment-name (subject-experiment subject)))

(defmethod value ((subject subject))
  (variant-payload (subject-variant subject)))
