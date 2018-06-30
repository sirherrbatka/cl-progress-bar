(in-package #:cl-user)


(asdf:defsystem cl-progress-bar
  :name "cl-progress-bar"
  :license "MIT"
  :author "Marek Kochanowicz"
  :maintainer "Marek Kochanowicz"
  :depends-on (:bordeaux-threads :documentation-utils-extensions)
  :defsystem-depends-on (:prove-asdf)
  :serial T
  :pathname "src"
  :components ((:file "package")
               (:file "progress")
               (:file "control")
               (:file "docstrings")))
