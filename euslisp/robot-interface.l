(load "package://pr2eus/robot-interface.l")
(load "package://jishupro/models/robot.l")
(ros::load-ros-manifest "control_msgs")

(defclass iorobot-interface
  :super robot-interface
  :slots ())
(defmethod iorobot-interface
  (:init (&rest args)
	 (send-super* :init :robot iorobot args)
	 (mapcar #'(lambda (ctype)
		     (send self :add-controller ctype))
		 (send self :default-controller-list)))
  (:default-controller-list ()
			    (list :fullbody-controller))
  (:default-controller ()
		       (mapcar #'(lambda (ctype) (car (send self ctype))) (send self :default-controller-list)))
  (:fullbody-controller ()
   ()
   (list
    (list
     (cons :controller-action "fullbody_controller/follow_joint_trajectory")
     (cons :controller-state "fullbody_controller/state")
     (cons :action-type control_msgs::FollowJointTrajectoryAction)
     (cons :joint-names (mapcar #'(lambda (n) (if (symbolp n) (symbol-name n) n)) (send-all (send robot :joint-list) :name))))))
  )

(setq *ri* (instance iorobot-interface :init))
(setq *io* (make-iorobot))
(objects (list *io*))

(defun a ()
  (send *ri* :angle-vector (send *io* :angle-vector) 3000))

(defun w ()
  (walk-motion *io*))

(defun l ()
  (load "robot-interface.l"))

(defun bend-test ()
  (dotimes (i 5)
    (send *ri* :angle-vector (send *io* :bend-leg) 3000)
    (unix::sleep 3)
    (send *ri* :angle-vector (send *io* :reset-pose) 3000)
    (unix::sleep 3)
    ))


(defun ww ()
  (let ((c (walk-motion *io*)))
    (send *ri* :angle-vector-sequence
          (mapcar #'(lambda (x) (cadr (memq :angle-vector x))) c)
          (make-list (length c) :initial-element 300)
          )
  ))

(defun ww-test ()
  (let* ((c (walk-motion *io*))
         (len (length c))
         (times (mapcar #'(lambda (x) (cadr (memq :time x))) c)))
    (dotimes (i (1- len))
      (setf (elt times (- len i 1))
            (+ (* (- (elt times (- len i 1)) (elt times (- len 2)) 100)) 500)))
    (format t "~A~%" times)
    (send *ri* :angle-vector-sequence
          (mapcar #'(lambda (x) (cadr (memq :angle-vector x))) c)
          times
          )
  ))

(defun d (c)
  (angle-vector-sequence (mapcar #'(lambda (x) (cadr (memq :angle-vector x))) c)))
