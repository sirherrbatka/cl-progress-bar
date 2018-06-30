(in-package #:cl-user)


(defpackage :cl-progress-bar
  (:use #:common-lisp)
  (:export
   #:update-progress
   #:with-progress-bar
   #:*progress-bar*
   #:*progress-bar-enabled*))


(defpackage :cl-progress-bar.progress
  (:use #:common-lisp)
  (:export
   #:progress-bar
   #:mutex
   #:uncertain-size-progress-bar
   #:update-progress))
