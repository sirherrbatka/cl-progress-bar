# cl-progress-bar
Progress bars, just like in quicklisp!

# Description
This library provides almost the same code as used inside quicklisp for drawning progress bars. Differences includeare:
* Different API.
* Thread safety.
* Does not assume that progress bar are releated representing download progress. Finish message contains just formatted duration.

# Examples
Basic exapmle looks like this:
```
(defun perform-step () ; Calls to the update can occur anywhere.
  (sleep 1)
  (cl-progress-bar:update 1))

(setf cl-progress-bar:*progress-bar-enabled* t) ; nil by default, must be t to actually display anything.
(cl-progress-bar:with-progress-bar (5 "This is just a example. Number of steps is ~a." 5)
  (dotimes (i 5) (perform-step 1)))
```
The above should print the following message after executing.
```
This is just a example. Number of steps is 5.
==================================================
Finished in 5.00 seconds
```
The progress bar itself is composed from equal bars and will grow gradually.

Full blown example can be seen in cl-data-structures

Establishing progress bar: https://github.com/sirherrbatka/cl-data-structures/blob/2b3d8489819b18a1f914777fe1d13da7a72223c2/src/utils/clustering/external-functions.lisp#L71

Updating progress bar: https://github.com/sirherrbatka/cl-data-structures/blob/2b3d8489819b18a1f914777fe1d13da7a72223c2/src/utils/clustering/internal-functions.lisp#L355
