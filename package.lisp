(defpackage #:cl-vmd
  (:use #:cl #:uiop #:usocket)
  (:export #:start-vmd
	   #:stop-vmd))

(in-package #:cl-vmd)


;; settings
(defparameter *vmd-executable*
  "/Applications/VMD.app/Contents/vmd/vmd_MACOSXARM64")

(defparameter *vmd-script*
  "~/git/cl-vmd/server.tcl")

(defparameter *host* "localhost")
(defparameter *port* 12345)

(defparameter *vmd-process* nil)


;; display molecule => mol new ... ; display update

;; main
(defun vmd/start ()
  (setf *vmd-process*
        (uiop:launch-program
         (list *vmd-executable*
               "-e" *vmd-script*)
         :output :interactive
         :error-output :interactive
         :wait nil)))

(defun vmd/send (command &optional (host *host*) (port *port*))
  (usocket:with-client-socket (socket stream host port)
    (format stream "~a~%" command)
    (force-output stream)
    (read-line stream nil nil)))


(defun vmd/stop ()
  (vmd/send "quit"))


;; ideas
(defun vmd/new-molecule (path &optional (repr nil))
  (vmd/send (concatenate 'string "mol new " path))
  (vmd/send "display update")
  (if repr
      (progn
	(vmd/send (concatenate 'string "mol representation " repr))
	(vmd/send "display update"))))

;; another idea would be to have a better DSL
;; first, add something like
;; (vmd/script
;;    (mol new ...)
;;    (display update))
;; a macro that would turn this into many calls
;; (vmd/send "mol new ...")
;; (vmd/send "display update")
;; etc, something that could help to script it fast instead of sending each time manually
;; it should reset before reexecuting


;; then, we could make a function in cl-gro that could (visualize *system*)
;; ) save a temporary file, load it, and then we could just script
;; or something like
;; (visualize *system* :commands (mol new add ...))
