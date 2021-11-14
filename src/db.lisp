(defpackage ab-testing/db
  (:use #:cl)
  (:import-from #:cl-dbi
                #:connect
                #:disconnect)
  (:import-from #:mito
                #:create-dao)
  (:import-from #:ab-testing/models/experiment
                #:experiment)
  (:import-from #:ab-testing/models/variant
                #:variant)
  (:export #:with-connection
           #:seed-db))
(in-package #:ab-testing/db)

(defparameter *application-root* (asdf:system-source-directory :ab-testing))

(defmacro with-connection (&body body)
  `(let ((mito:*connection* (dbi:connect-cached :sqlite3 :database-name
                                                (merge-pathnames #P"db/ab-testing.db" *application-root*))))
     (unwind-protect
          (progn ,@body)
       (dbi:disconnect mito:*connection*))))

(defun seed-db ()
  (with-connection
      (let ((experiments '(("button_color" . (("#FF0000" . 33) ("#00FF00" . 33) ("#0000FF" . 33)))
                           ("price" . ((10 . 75) (20 . 10) (50 . 5) (5 . 10))))))
        (dolist (experiment experiments)
          (let ((experiment-instance (create-dao 'experiment :name (car experiment))))
            (dolist (variant (cdr experiment))
              (create-dao 'variant :payload (car variant) :weight (cdr variant) :experiment experiment-instance)))))))
