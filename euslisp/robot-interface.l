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
          (make-list (length c) :initial-element 200)
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
