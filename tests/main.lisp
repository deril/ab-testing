(defpackage ab-testing/tests/main
  (:use :cl
        :ab-testing
        :rove))
(in-package :ab-testing/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :ab-testing)' in your Lisp.

(deftest test-target-1
  (testing "should (= 1 1) to be true"
    (ok (= 1 1))))
