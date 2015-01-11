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

(defun bend-test ()
  (dotimes (i 5)
    (send *ri* :angle-vector (send *io* :bend-leg) 3000)
    (unix::sleep 3)
    (send *ri* :angle-vector (send *io* :reset-pose) 3000)
    (unix::sleep 3)
    ))
