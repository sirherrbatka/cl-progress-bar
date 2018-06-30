(in-package #:cl-user)


(defpackage :cl-progress-bar
  (:use #:common-lisp)
  (:export
   #:update
   #:with-progress-bar
   #:*progress-bar*
   #:*progress-bar-enabled*))


(defpackage :cl-progress-bar.progress
  (:use #:common-lisp)
  (:export
   #:progress-bar
   #:start-display
   #:finish-display
   #:mutex
   #:uncertain-size-progress-bar
   #:update-progress))
