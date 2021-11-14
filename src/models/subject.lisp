(defpackage ab-testing/models/subject
  (:use #:cl
        #:mito)
  (:import-from #:ab-testing/models/variant
                #:variant)
  (:export :subject))
(in-package ab-testing/models/subject)

(deftable subject ()
  ((device-id :col-type :text)
   (variant :col-type (or variant :null))))
