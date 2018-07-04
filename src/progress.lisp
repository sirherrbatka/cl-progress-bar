(in-package #:cl-progress-bar.progress)

(defclass progress-bar ()
  ((start-time
    :initarg :start-time
    :accessor start-time)
   (end-time
    :initarg :end-time
    :accessor end-time)
   (progress-character
    :initarg :progress-character
    :accessor progress-character)
   (character-count
    :initarg :character-count
    :accessor character-count
    :documentation "How many characters wide is the progress bar?")
   (characters-so-far
    :initarg :characters-so-far
    :accessor characters-so-far)
   (update-interval
    :initarg :update-interval
    :accessor update-interval
    :documentation "Update the progress bar display after this many
    internal-time units.")
   (last-update-time
    :initarg :last-update-time
    :accessor last-update-time
    :documentation "The display was last updated at this time.")
   (total
    :initarg :total
    :accessor total
    :documentation "The total number of units tracked by this progress bar.")
   (progress
    :initarg :progress
    :accessor progress
    :documentation "How far in the progress are we?")
   (mutex
    :initarg :mutex
    :reader mutex
    :documentation "Just a mutex, allows progress bar to be thread safe.")
   (pending
    :initarg :pending
    :accessor pending
    :documentation "How many raw units should be tracked in the next
    display update?"))
  (:default-initargs
   :mutex (bt:make-lock)
   :progress-character #\=
   :character-count 50
   :characters-so-far 0
   :update-interval (floor internal-time-units-per-second 4)
   :last-update-time 0
   :total 0
   :progress 0
   :pending 0))

(defgeneric start-display (progress-bar))
(defgeneric update-progress (progress-bar unit-count))
(defgeneric update-display (progress-bar))
(defgeneric finish-display (progress-bar))
(defgeneric elapsed-time (progress-bar))
(defgeneric units-per-second (progress-bar))

(defmethod start-display (progress-bar)
  (setf (last-update-time progress-bar) (get-internal-real-time))
  (setf (start-time progress-bar) (get-internal-real-time))
  (fresh-line)
  (finish-output))

(defmethod update-display (progress-bar)
  (incf (progress progress-bar) (pending progress-bar))
  (setf (pending progress-bar) 0)
  (setf (last-update-time progress-bar) (get-internal-real-time))
  (unless (zerop (progress progress-bar))
    (let* ((showable (floor (character-count progress-bar)
                            (/ (total progress-bar) (progress progress-bar))))
           (needed (- showable (characters-so-far progress-bar))))
      (setf (characters-so-far progress-bar) showable)
      (dotimes (i needed)
        (write-char (progress-character progress-bar)))
      (finish-output))))

(defmethod update-progress (progress-bar unit-count)
  (incf (pending progress-bar) unit-count)
  (let ((now (get-internal-real-time)))
    (when (< (update-interval progress-bar)
             (- now (last-update-time progress-bar)))
      (update-display progress-bar))))

(defconstant +seconds-in-one-hour+ 3600)
(defconstant +seconds-in-one-minute+ 60)

(defun time-in-seconds-minutes-hours (in-seconds)
  (format t "Finished in")
  (when (>= in-seconds +seconds-in-one-hour+)
    (let* ((hours (floor (/ in-seconds +seconds-in-one-hour+))))
      (decf in-seconds (* hours +seconds-in-one-hour+))
      (format t " ~a hour~p" hours hours)))
  (when (>= in-seconds +seconds-in-one-minute+)
    (let* ((minutes (floor (/ in-seconds +seconds-in-one-minute+))))
      (decf in-seconds (* minutes +seconds-in-one-minute+))
      (format t " ~a minute~p" minutes minutes)))
  (unless (zerop in-seconds)
    (format t " ~$ seconds" in-seconds)))

(defmethod finish-display (progress-bar)
  (update-display progress-bar)
  (setf (end-time progress-bar) (get-internal-real-time))
  (terpri)
  (time-in-seconds-minutes-hours (elapsed-time progress-bar))
  (finish-output)
  (unless (= (progress progress-bar) (total progress-bar))
    (warn "Expected TOTAL is ~a but progress at the moment of finishing is ~a"
          (total progress-bar)
          (progress progress-bar))))

(defmethod elapsed-time (progress-bar)
  (/ (- (end-time progress-bar) (start-time progress-bar))
     internal-time-units-per-second))

(defmethod units-per-second (progress-bar)
  (if (plusp (elapsed-time progress-bar))
      (/ (total progress-bar) (elapsed-time progress-bar))
      0))

(defparameter *uncertain-progress-chars* "?")

(defclass uncertain-size-progress-bar (progress-bar)
  ((progress-char-index
    :initarg :progress-char-index
    :accessor progress-char-index)
   (units-per-char
    :initarg :units-per-char
    :accessor units-per-char))
  (:default-initargs
   :total 0
   :progress-char-index 0
   :units-per-char (floor (expt 1024 2) 50)))

(defmethod update-progress :after ((progress-bar uncertain-size-progress-bar)
                                   unit-count)
  (incf (total progress-bar) unit-count))

(defmethod progress-character ((progress-bar uncertain-size-progress-bar))
  (let ((index (progress-char-index progress-bar)))
    (prog1
        (char *uncertain-progress-chars* index)
      (setf (progress-char-index progress-bar)
            (mod (1+ index) (length *uncertain-progress-chars*))))))

(defmethod update-display ((progress-bar uncertain-size-progress-bar))
  (setf (last-update-time progress-bar) (get-internal-real-time))
  (multiple-value-bind (chars pend)
      (floor (pending progress-bar) (units-per-char progress-bar))
    (setf (pending progress-bar) pend)
    (dotimes (i chars)
      (write-char (progress-character progress-bar))
      (incf (characters-so-far progress-bar))
      (when (<= (character-count progress-bar)
                (characters-so-far progress-bar))
        (terpri)
        (setf (characters-so-far progress-bar) 0)
        (finish-output)))
    (finish-output)))
