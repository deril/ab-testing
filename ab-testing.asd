(defsystem "ab-testing"
  :version "0.1.0"
  :author "Dmytro Bihniak"
  :license "LGPL"
  :depends-on ("hunchentoot"
               "easy-routes"
               "mito"
               "jonathan")
  :components ((:module "src"
                :components
                ((:file "main")
                 (:file "db" :depends-on ("models"))
                 (:file "web" :depends-on ("db" "experiment-service"))
                 (:file "experiment-service")
                 (:module "models"
                          :components
                          ((:file "experiment")
                           (:file "variant" :depends-on ("experiment"))
                           (:file "subject" :depends-on ("variant")))))))
  :description ""
  :in-order-to ((test-op (test-op "ab-testing/tests"))))

(defsystem "ab-testing/tests"
  :author "Dmytro Bihniak"
  :license "LGPL"
  :depends-on ("ab-testing"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for ab-testing"
  :perform (test-op (op c) (symbol-call :rove :run c)))
