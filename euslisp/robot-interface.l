(load "package://pr2eus/robot-interface.l")
(load "package://pr2eus/speak.l")
(load "package://jishupro/models/robot.l")
(ros::load-ros-manifest "control_msgs")

(ros::roseus "iorobot_interface")
(ros::advertise "robotsound" sound_play::SoundRequest 5)

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
    ;;(send *ri* :angle-vector (send *io* :bend-leg) 3000)
    (send *ri* :angle-vector (send *io* :kneel) 3000)
    (unix::sleep 3)
    ;;(send *ri* :angle-vector (send *io* :init-pose) 3000)
    (send *ri* :angle-vector (send *io* :reset-pose) 3000)
    (unix::sleep 3)
    ))

(defun ww ()
  (let ((c (walk-motion *io*)))
    (send *ri* :angle-vector-sequence
          (mapcar #'(lambda (x) (cadr (memq :angle-vector x))) c)
          (make-list (length c) :initial-element 100)
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

(defun r ()
  (send *io* :fix-leg-to-coords (make-coords))
  (send *io* :update-descendants)
  (send *irtviewer* :draw-objects))


;; (defun ik-demo0
;;   (&key (step 10)        ;;stepは一回のループで目標を動かす距離
;;         (use-wheel nil)  ;;車輪を使ってIKを解くかどうか
;;         )
;;   ;;逆運動学が解きやすい初期姿勢に変更
;;   (send *io* :reset-pose)
;;   (send *irtviewer* :draw-objects)
;;   ;;
;;   ;;'e'を押すまで続ける
;;   (warning-message 2 ";; if stop, then enter e~%")
;;   (warning-message 2 ";;  h:left, j:down, k:up, l:right, f:forward, b:back~%")
;;   (let (w goal-endcoords ll)
;;     ;;もし腕しか使わない場合はlinklistをあらかじめ用意しておく
;;     (when (not use-wheel)
;;       (setq ll
;;             (send *io* :link-list
;;                   (send *io* :rarm :end-coords :parent) ;;ここまで
;;                   )))
;;     ;;目標座標を作成する(デフォルトは、台車の手先位置と同じにする)
;;     (setq goal-endcoords
;;           (make-cascoords :pos (send *io* :rarm :end-coords :worldpos)))
;;     ;;ループを回す
;;     (while t
;;       (setq w (read-line)) ;;文字を取得
;;       ;;文字によって操作を変える
;;       (cond
;;        ((equal w "e")
;;         (return-from nil)) ;;loopから抜けて終了
;;        ((equal w "h")  ;;左へ動かす
;;         (send goal-endcoords :locate (float-vector 0 step 0)))
;;        ((equal w "j")  ;;下へ動かす
;;         (send goal-endcoords :locate (float-vector 0 0 (* -1 step))))
;;        ((equal w "k")  ;;上へ動かす
;;         (send goal-endcoords :locate (float-vector 0 0 step)))
;;        ((equal w "l")  ;;右へ動かす
;;         (send goal-endcoords :locate (float-vector 0 (* -1 step) 0)))
;;        ((equal w "f")  ;;前へ動かす
;;         (send goal-endcoords :locate (float-vector step 0 0)))
;;        ((equal w "b")  ;;後へ動かす
;;         (send goal-endcoords :locate (float-vector (* -1 step) 0 0)))
;;        ((not w)) ;;何も入れられなければ何もしない
;;        (t
;;         (warning-message 2 ";; no such command~%")
;;         (warning-message 2 ";; if stop, then enter e~%")
;;         (warning-message 2 ";;  h:left, j:down, k:up, l:right, f:forward, b:back~%")
;;         ))
;;       ;;目標値end-coordsに向かって逆運動学を解いて、動かす
;;       ;;  solve-ikという逆運動学をとくmethodを呼び出す。
;;       (cond
;;        (use-wheel ;;車輪を使う場合
;;         (send *io* :rarm :inverse-kinematics goal-endcoords :rotation-axis nil :debug-view nil))
;;        (t
;;         (send *io* :rarm :inverse-kinematics goal-endcoords :rotation-axis nil :debug-view nil :link-list ll :move-target (send *io* :rarm :end-coords)))
;;        )
;;       (send *irtviewer* :objects (list *io* goal-endcoords))
;;       (send *irtviewer* :draw-objects)
;;       ))
;;   (warn ";; finished~%")
;;   )


(defun walk-single()
  (let ((tmp (walk-motion-single-support *io*)))
    (send *ri* :angle-vector-sequence
          (mapcar #'(lambda (x) (cadr (memq :angle-vector x))) tmp)
          (make-list (length tmp) :initial-element 500)
    ))
  )


(defun stand-up ()
  (send *io* :hold-out)
  (send *ri* :angle-vector (send *io* :angle-vector) 3000)
  (unix::sleep 3)
  (send *io* :kneel)
  (send *ri* :angle-vector (send *io* :angle-vector) 3000)
  (unix::sleep 3)
  (send *io* :reset-pose)
  (send *ri* :angle-vector (send *io* :angle-vector) 3000)
  (unix::sleep 3)
  )


(defun shake-head ()
  (let ((i 0))
    (do-until-key ()
      ;;(setf (elt (send *io* :angle-vector) 18) i)
      (setq tmp (send *io* :angle-vector))
      (setf (elt tmp 18) i)
      (format t "~A~%" (elt tmp 18))
      (format t "~A~%" (send *io* :angle-vector ))
      (send *ri* :angle-vector (send *io* :angle-vector tmp))
      (unix::sleep 1)
      (setq i (+ i 10))
      (setq i (mod i 180))
      )))


(defun b ()
  (send *ri* :angle-vector (send *io* :bend-arm)))


(defun push-up ()
  (speak-en "push up!")
  (do-until-key ()
    (send *ri* :angle-vector (send *io* :bend-arm) 1000)
    (unix::sleep 1)
    (send *ri* :angle-vector (send *io* :bend-arm2) 1000)
    (unix::sleep 1)
    ))


;; (defun return ()
;;   (send *ri* :angle-vector (send *io* :bend-leg-arm2))
;;   (unix::sleep 1)
;;   (send *ri* :angle-vector (send *io* :bend-leg-arm) 100)
;; )


;; (defun walk-motion
;;   (robot)
;;   "walking motion using preview-control, gait-generator, and fullbody ik"
;;   (let* ((is-small-robot
;;           (< (abs (elt (send (send (car (send robot :links)) :transformation (apply #'midcoords 0.5 (send robot :legs :end-coords))) :worldpos) 2)) 400))
;;          (default-step-height (if is-small-robot 2
;;           :default-step-height default-step-height)
;;     )
;;   ;;
;;   (warn ";; test2 ;; calc footstep-list from go pos param~%")
;;   (objects (list robot
;;                  (apply #'midcoords 0.5 (send robot :legs :end-coords))
;;                  (send (send (apply #'midcoords 0.5 (send robot :legs :end-coords)) :translate (float-vector 500 150 0)) :rotate (deg2rad 45) :z)))
;;   (if is-small-robot (send robot :gen-footstep-parameter :ratio 0.3))
;;   (send robot :calc-walk-pattern-from-footstep-list
;;         (send robot :go-pos-params->footstep-list
;;               500 0 0) ;; x[mm] y[mm] th[deg]
;;         :debug-view :no-message
;;         :default-step-height default-step-height)
;;   )))


(defun my-walk ()
  (send *ri* :angle-vector (send *io* :angle-vector #f(-2.734934e-05 20.7265 -55.8641 100.728 47.8641 20.7267 -1.913858e-05 17.37 -34.8734 69.7468 34.8734 22.3701 0.0 -60.0 -30.0 0.0 60.0 30.0 0.0)))
  (unix::sleep 1)
  (send *ri* :angle-vector (send *io* :angle-vector #f(-2.734934e-05 20.7265 -70.8641 100.728 47.8641 20.7267 -1.913858e-05 17.37
                                                                     -34.8734 69.7468 34.8734 22.3701 0.0 -60.0 -30.0 0.0 60.0 30.0 0.0)))
  (unix::sleep 3)
  (send *ri* :angle-vector (send *io* :angle-vector #f(-2.734934e-05 20.7265 -55.8641 95.728 45.8641 20.7267 -1.913858e-05 17.37
                                                                     -34.8734 69.7468 38.8734 10.3701 0.0 -60.0 -30.0 0.0 60.0 30.0 0.0)))
  (unix::sleep 3)
  )
