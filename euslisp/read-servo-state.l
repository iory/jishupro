#! /usr/bin/env roseus

(ros::load-ros-manifest "dynamixel_msgs")
(ros::roseus "read_servo_state")

(defvar *dof* 19)
(defvar *leg-dof* 6)
(defvar *arm-dof* 3)
(defvar *head-dof* 1)
(setq *state-list* (make-list *dof*))

(defun dxl-state-cb-rleg
    (msg)
  (setf (elt *state-list* (1- (read-from-string (string-left-trim "rleg_joint" (send msg :name))))) msg))
(defun dxl-state-cb-lleg
    (msg)
  (setf (elt *state-list* (+ *leg-dof* (1- (read-from-string (string-left-trim "lleg_joint" (send msg :name)))))) msg))
(defun dxl-state-cb-rarm
    (msg)
  (setf (elt *state-list* (+ (* 2 *leg-dof*) (1- (read-from-string (string-left-trim "rarm_joint" (send msg :name)))))) msg))
(defun dxl-state-cb-larm
    (msg)
  (setf (elt *state-list* (+ (* 2 *leg-dof*) *arm-dof* (1- (read-from-string (string-left-trim "larm_joint" (send msg :name)))))) msg))
(defun dxl-state-cb-head
    (msg)
  (setf (elt *state-list* (+ (* 2 *leg-dof*) (* 2 *arm-dof*) (1- (read-from-string (string-left-trim "head_joint" (send msg :name)))))) msg))


;; registaration of subscriber
(dotimes (i *leg-dof*)
  (ros::subscribe (format nil "/rleg_j~d_controller/state" (1+ i))
                  dynamixel_msgs::JointState
                  #'dxl-state-cb-rleg))
(dotimes (i *leg-dof*)
  (ros::subscribe (format nil "/lleg_j~d_controller/state" (1+ i))
                  dynamixel_msgs::JointState
                  #'dxl-state-cb-lleg))
(dotimes (i *arm-dof*)
  (ros::subscribe (format nil "/rarm_j~d_controller/state" (1+ i))
                  dynamixel_msgs::JointState
                  #'dxl-state-cb-rarm))
(dotimes (i *arm-dof*)
  (ros::subscribe (format nil "/larm_j~d_controller/state" (1+ i))
                  dynamixel_msgs::JointState
                  #'dxl-state-cb-larm))
(dotimes (i *head-dof*)
  (ros::subscribe (format nil "/head_j~d_controller/state" (1+ i))
                  dynamixel_msgs::JointState
                  #'dxl-state-cb-head))

;; publisher
;; (dotimes (i *leg-dof*)
;;   (ros::advertise (format nil "/rleg_j~d_controller/state" (1+ i))
;;                   std_msgs::Float64
;;                   1))
;; (dotimes (i *leg-dof*)
;;   (ros::advertise (format nil "/lleg_j~d_controller/state" (1+ i))
;;                   std_msgs::Float64
;;                   1))
;; (dotimes (i *arm-dof*)
;;   (ros::advertise (format nil "/rarm_j~d_controller/state" (1+ i))
;;                   std_msgs::Float64
;;                   1))
;; (dotimes (i *arm-dof*)
;;   (ros::advertise (format nil "/larm_j~d_controller/state" (1+ i))
;;                   std_msgs::Float64
;;                   1))
;; (dotimes (i *head-dof*)
;;   (ros::advertise (format nil "/head_j~d_controller/state" (1+ i))
;;                   std_msgs::Float64
;;                   1))
(dotimes (i *dof*)
  (ros::advertise (format nil "/arm_j~d_controller/angle" (1+ i))
                  std_msgs::Float32
                  10))

(dotimes (i *dof*)
  (ros::advertise (format nil "/arm_j~d_controller/temperature" (1+ i))
                  std_msgs::Float32
                  10))

(ros::rate 10)
(while (ros::ok)
  (ros::spin-once)
  ;;(pprint (send-all *state-list* :slots))
  ;;(format t "===========================~%" )
  (dotimes (i *dof*)
    (if (not (null (elt *state-list* i)))
        (progn
          ;;(format t "~A~%" (send (elt *state-list* i) :current_pos))
          (ros::publish (format nil "/arm_j~d_controller/angle" (1+ i))
                        (instance std_msgs::Float32 :init :data (rad2deg (send (elt *state-list* i) :current_pos))))
          (ros::publish (format nil "/arm_j~d_controller/temperature" (1+ i))
                        (instance std_msgs::Float32 :init :data (elt (send (elt *state-list* i) :motor_temps) 0))))
        ;; nil
          (ros::publish (format nil "/arm_j~d_controller/angle" (1+ i))
                        (instance std_msgs::Float32 :init :data (- 180 (random 180))))
          (ros::publish (format nil "/arm_j~d_controller/temperature" (1+ i))
                        (instance std_msgs::Float32 :init :data (random 50)))
        ))
  (ros::sleep))


(defun test-read-state () ;; 各サーボの状態を全軸分読み出す
  (ros::spin-once)
  (pprint (send-all *state-list* :slots))
  t)
(warn ";; (test-read-state)~%")

(defun a () (test-read-state))
