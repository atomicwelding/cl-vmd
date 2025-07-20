(defpackage #:cl-vmd
  (:use #:cl #:uiop #:usocket)
  (:export #:start-vmd
	   #:send-vmd
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

;; main
(defun start-vmd ()
  (setf *vmd-process*
        (uiop:launch-program
         (list *vmd-executable*
	       "-dispdev" "opengl"
               "-e" *vmd-script*)
         :output :interactive
         :error-output :interactive
         :wait nil)))


(defun send-vmd (command &optional (host *host*) (port *port*))
  (usocket:with-client-socket (socket stream host port)
    (format stream "~a~%" command)
    (force-output stream)
    (read-line stream nil nil)))

(defun stop-vmd ()
  (send-vmd "quit"))


