(defpackage #:cl-vmd
  (:use #:cl #:uiop #:usocket)
  (:export #:vmd/start
	   #:vmd/stop
	   #:vmd/cmd
	   #:vmd/script))

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

(defun vmd/restart ()
  (vmd/stop)
  (vmd/start))

(defmacro vmd/cmd (form)
  `(vmd/send
    (format nil "~{~a~^ ~}"
            (list ,@(mapcar (lambda (x)
                              (if (symbolp x)
                                  `(string-downcase (symbol-name ',x))
                                  x))
                            form)))))

(defmacro vmd/script (&rest commands)
  `(progn
     ,@(mapcar (lambda (cmd)
                 `(vmd/cmd ,cmd))
               commands)))
;; ideas


;; test
;; (vmd/start)

(vmd/script
 (display resetview)
 (mol new "/Users/weld/git/cl-gro/example.gro")
 (mol representation VDW)
 (mol addrep 0)
 (display update))
