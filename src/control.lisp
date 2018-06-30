(in-package #:cl-progress-bar)

(defvar *progress-bar* nil)
(defparameter *progress-bar-enabled* nil)

(declaim (inline update))
(defun update (unit-count &optional (progress-bar *progress-bar*))
  (check-type unit-count (integer 1 *))
  (check-type progress-bar (or null cl-progress-bar.progress:progress-bar))
  (unless (null progress-bar)
    (bt:with-lock-held ((cl-progress-bar.progress:mutex progress-bar))
      (cl-progress-bar.progress:update-progress progress-bar unit-count))))

(defun make-progress-bar (total)
  (check-type total (or null (integer 1 *)))
  (if (or (not total) (zerop total))
      (make-instance 'cl-progress-bar.progress:uncertain-size-progress-bar)
      (make-instance 'cl-progress-bar.progress:progress-bar
                     :total total)))

(defmacro with-progress-bar ((steps-count description &rest desc-args) &body body)
  (let ((!old-bar (gensym)))
    `(let* ((,!old-bar *progress-bar*)
            (*progress-bar* (or ,!old-bar
                                (when *progress-bar-enabled*
                                  (make-progress-bar ,steps-count)))))
       (unless (eq ,!old-bar *progress-bar*)
         (fresh-line)
         (format t ,description ,@desc-args)
         (cl-progress-bar.progress:start-display *progress-bar*))
       (prog1 (progn ,@body)
         (unless (eq ,!old-bar *progress-bar*)
           (cl-progress-bar.progress:finish-display *progress-bar*))))))
