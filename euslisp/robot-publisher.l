#! /usr/bin/env roseus

(load "package://jishupro/models/robot.l")

(setq *robot-forms*
      '((iorobot)))
#+:rbrain-basic
(setq *robot-forms* (append  *robot-forms* '(iorobot)))

(ros::roseus "robot_publisher")

(setq *tfb* (instance ros::transform-broadcaster :init))
(setq *tfl* (instance ros::transform-listener :init))
(setq *robot-msgs* nil)

(if (ros::has-param "~robot")
    (setq *robot-forms* (read-from-string (ros::get-param "~robot"))))

(let ((x (ros::get-param "~x" 0)) (y (ros::get-param "~y" 0)))
  (dolist (robot-form *robot-forms*)
    (ros::ros-info ">> ~A~%" robot-form)
    (let* ((robot (make-iorobot))
           (robot-name (send robot :name))
           (robot-frame-id (format nil "/~A" (string-downcase robot-name)))
           msg)
      (format t "==============~A~%" robot)
      (ros::advertise robot-frame-id visualization_msgs::Marker 5)
      (ros::ROS-INFO "loading and advertise ~a" robot-name)
      (setq tm (instance mtimer :init))
      (send tm :start)
      (setq msg (object->marker-msg robot
                                    (instance std_msgs::header
                                              :init :stamp (ros::time-now)
                                              :frame_id robot-frame-id)))
      (push msg *robot-msgs*)
      (ros::ROS-INFO "~a ~a ~a" robot-name (send robot :worldpos)
                     (ros::tf-point->pos (send msg :pose :position)))
      (ros::ROS-INFO "object->marker convert time ~a[ms]"
                     (* 1000 (send tm :stop)))

      (send robot :locate (float-vector x y 0) :world)
      (if (> (incf y 800) 4000) (setq x (- x 1000) y 0))
      (send *tfb* :send-transform robot "/tmp" robot-frame-id)
      )))

(ros::rate 5)
(do-until-key
 (dolist (msg *robot-msgs*)
   (let (frame-id)
     (setq frame-id (send msg :header :frame_id))
     (print (list msg frame-id (get msg :published) (ros::get-num-subscribers frame-id)))
     (when (and (null (get msg :published))
                (> (ros::get-num-subscribers frame-id) 0))
       (send msg :header :stamp (ros::time-now))
       (ros::ROS-INFO "publish marker ~A" frame-id)
       (ros::publish frame-id msg)
       (setf (get msg :published) t))
     (ros::ROS-INFO "publish coords ~A" frame-id)
     (setq coords (send *tfl* :lookup-transform "/tmp" frame-id (ros::time 0)))
     (send coords :rotate 0.1 :z)
     (send *tfb* :send-transform coords "/tmp" frame-id)))
 (ros::spin-once)
 (ros::sleep))
