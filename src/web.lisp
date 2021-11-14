(defpackage ab-testing/web
  (:use #:cl
        #:easy-routes)
  (:import-from #:ab-testing/db
                #:with-connection))
(in-package :ab-testing/web)

(defun @json (next)
  (setf (hunchentoot:content-type*) "application/json")
  (funcall next))

(defun @db (next)
  (with-connection
      (funcall next)))

(defroute experiments
    ("/experiments"
     :method :get
     :decorators ((@json @db)))
    ()
  "List of active experiments for the device."
  (hunchentoot:log-message* :info "Device-Tocken:~A" (hunchentoot:header-in* :device-token))
  (format nil (jojo:to-json '((:name "button_color" :value "#FF0000")))))
