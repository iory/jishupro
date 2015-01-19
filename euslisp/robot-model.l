(load "package://jishupro/models/robot.l")

(setq *ri* (make-iorobot))
(objects (list *ri*))

(defun r ()
  (send *ri* :reset-pose))

(defun l ()
  (load "robot.l")
  (a))


(defun i (arm)
  (let ((tmp))
    (case arm
      (:larm
       (setq tmp (make-cascoords :pos (send *ri* :larm :end-coords :worldpos)))
       (send *ri* :larm :inverse-kinematics tmp :revert-if-fail nil)
       )
      (:rleg
       (setq tmp (make-cascoords :pos (send *ri* :rleg :end-coords :worldpos)))
       (send *ri* :rleg :inverse-kinematics tmp)
       )
      (:rarm
       (setq tmp (make-cascoords :pos (send *ri* :rarm :end-coords :worldpos)))
       ;;(send tmp :locate #f(0 100 100))
       (send *ri* :rarm :inverse-kinematics tmp :revert-if-fail nil)
       )
      (:lleg
       (setq tmp (make-cascoords :pos (send *ri* :lleg :end-coords :worldpos)))
       (send *ri* :lleg :inverse-kinematics tmp)
       )
      )))
