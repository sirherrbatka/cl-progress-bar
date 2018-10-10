# cl-progress-bar
Progress bars, just like in the quicklisp!

# Description
This library provides almost the same code as used inside quicklisp for drawning progress bars. Differences includeare:
* Different API.
* Thread safety.
* Does not assume that progress bar is representing download progress. Finish message contains just formatted duration (in hours, minutes, seconds format).

# Examples
Basic exapmle demonstrated below:
```
(defun perform-step () ; Calls to the update can occur anywhere.
  (sleep 1)
  (cl-progress-bar:update 1))

(setf cl-progress-bar:*progress-bar-enabled* t) ; nil by default, must be t to actually display anything.
(cl-progress-bar:with-progress-bar (5 "This is just a example. Number of steps is ~a." 5)
  (dotimes (i 5) (perform-step)))
```
The above should print the following message after execution.
```
This is just a example. Number of steps is 5.
==================================================
Finished in 5.00 seconds
```
The progress bar itself is composed from '=' and will grow gradually.

Full blown example can be seen in cl-data-structures

Establishing progress bar: https://github.com/sirherrbatka/cl-data-structures/blob/2b3d8489819b18a1f914777fe1d13da7a72223c2/src/utils/clustering/external-functions.lisp#L71

Updating progress bar: https://github.com/sirherrbatka/cl-data-structures/blob/2b3d8489819b18a1f914777fe1d13da7a72223c2/src/utils/clustering/internal-functions.lisp#L355

# Threads
Because progress bar instance is bound to the special variable, in case of calling the update function on different thread you should ensure that cl-progress-bar:*progress-bar* is bound yourself.
