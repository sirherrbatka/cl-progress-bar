(in-package #:cl-progress-bar)

(docs:define-docs
  :formatter docs.ext:rich-aggregating-formatter

  (variable *progress-bar*
    (:description "Current progress bar or NIL if there is no progress bar active. Should not be manipulated manually."))

  (variable *progress-bar-enabled*
    (:description "Boolean. T if progress bar should be outputed."))

  (function with-progress-bar
    (:description "Macro. Build active progress bar. Requires size and description that will be printed out to the REPL. If *progress-bar-endabled* is nil or there is another progress bar active already progress bar will not be shown."
     :arguments-and-values ((steps-count "Total number of steps that are expected before finish is reached.")
                            (description "FORMAT formula that should be printed when starting process.")
                            (desc-args "Arguments to FORMAT, should be compatible with description formula."))
     :notes "Because with-progress-bar handles cases where another progress-bar is active it is generally safe to nest code with this macro on call stack. However, top level with-progress-bar should contain correct steps-count."))

  (function update-progress
    (:description "Notify progress bar about step completion."
     :arguments-and-values ((unit-count "How many steps has been finished?")
                            (progress-bra "Instance of progress-bar. Usually should be left with default (namely: *progress-bar*)."))
     :thread-safety "This function is thread safe.")))
