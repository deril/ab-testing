(defpackage ab-testing/web
  (:use #:cl
        #:easy-routes
        #:jojo)
  (:import-from #:ab-testing/db
                #:with-connection)
  (:import-from #:ab-testing/experiment-service
                #:subjects-for
                #:statistic)
  (:import-from #:ab-testing/models/subject
                #:subject)
  (:local-nicknames (:subject :ab-testing/models/subject)))
(in-package :ab-testing/web)

(defun @json (next)
  (setf (hunchentoot:content-type*) "application/json")
  (funcall next))

(defun @db (next)
  (with-connection
      (funcall next)))

(defun @check-header (next)
  (if (hunchentoot:header-in* :device-token)
      (funcall next)
      (progn
        (setf (hunchentoot:return-code*) hunchentoot:+http-bad-request+)
        nil)))

(defroute experiments
    ("/experiments"
     :method :get
     :decorators (@json @db @check-header))
    ()
  "List of active experiments for the device."
  (let ((device-id (hunchentoot:header-in* :device-token)))
    (hunchentoot:log-message* :info "Device-Tocken:~A" device-id)
    (to-json (subjects-for device-id))))

(defroute stats
    ("/stats"
     :method :get
     :decorators (@json @db))
    ()
  "Statistic for experiments and devices"
  (to-json (statistic)))

(defmethod %to-json ((subject subject))
  (with-object
    (write-key-value "name" (subject:name subject))
    (write-key-value "value" (subject:value subject))))
