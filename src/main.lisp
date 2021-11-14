(defpackage ab-testing
  (:use #:cl)
  (:export :start
           :stop))
(in-package :ab-testing)

(defvar *handler* nil)

(defun start ()
  (when *handler*
    (restart-case (error "Server is already running.")
      (restart-server ()
        :report "Restart the server"
        (stop))))
  (setf *handler*
        (make-instance 'easy-routes:easy-routes-acceptor))
  (hunchentoot:start *handler*))

(defun stop ()
  (prog1
      (hunchentoot:stop *handler*)
    (setf *handler* nil)))
