(load "package://euslisp/jskeus/irteus/demo/walk-motion.l")
(load "package://jishupro/models/dynamixel-model.l")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; link definitions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; make-root-link
(defun make-robot-root-link ()
  (let ((b1 (make-cube 5 20 50))
        (b2 (make-cube 5 20 50)))
    (send b1 :put :face-color :slategray)
    (send b2 :put :face-coror :slategray)
    (send b1 :assoc b2)
    (send b2 :locate #f(-31 0 0))
    (send b1 :rotate pi/2 :y)
    (send b1 :rotate pi/2 :x)

    (let ((bl (instance bodyset-link
                        :init (make-cascoords)
                        :bodies (list b1 b2)
                        :name
                        :root-link)))
      (send bl :put :joint-coords
            (make-cascoords :coords
                            (send (send b1 :copy-worldcoords) :rotate pi/2 :x) :locate #f(0 0 0)))
      (send bl :assoc (send bl :get :joint-coords))
      bl)))

(defun make-robot-torso-link ()
  (let ((b1 (make-cube 40 70 100)))
    (send b1 :put :face-color :slategray)
    (send b1 :rotate pi/2 :x)
    (let ((bl (instance bodyset-link
                        :init (make-cascoords)
                        :bodies (list b1)
                        :name
                        :root-link)))
      (send bl :put :joint-coords
            (make-cascoords :coords
                            (send (send b1 :copy-worldcoords) :locate #f(0 0 0))))
      (send bl :assoc (send bl :get :joint-coords))
      bl)))

(defun make-robot-head-link1 ()
  (let ((b1 (make-dynamixel-AX-12A-motor-body)))
    (send b1 :rotate pi/2 :z)
    (send b1 :rotate -pi/2 :y)
    (let ((bs (list b1)))
      (dolist (b (cdr bs)) (send (car bs) :assoc b))
      (let ((bl (instance bodyset-link
                          :init (make-cascoords)
                          :bodies (list b1)
                          :name
                          :head-link1)))
        (send bl :translate (float-vector 0 0 100) :world)
        (send bl :put :joint-coords
              (make-cascoords :coords
                              (send (send (send (send (send (car bs) :get :joint-coords) :copy-worldcoords ) :locate #f(0 0 25)) :rotate 0 :z) :rotate 0 :x)))
        (send bl :assoc (send bl :get :joint-coords))
        bl))))

(defun make-robot-head-link2 ()
  (let ((c1 (make-cube 50 50 50)))
    (send c1 :put :face-color :slategray)
    (let ((bs (list c1)))
      ;; (car bs) is servo model
      (let ((bl (instance bodyset-link
                          :init (make-cascoords)
                          :bodies bs :name :head-link2)))
        (send bl :put :joint-coords
              (make-cascoords :coords (send (send (send (send (send (car bs) :copy-worldcoords) :locate #f(20 0 -40)) :rotate -pi/2 :y) :rotate -pi/2 :x) :rotate 0 :z)))
        (send bl :assoc (send bl :get :joint-coords))
        bl))))

;; arm-link
(defun make-robot-arm-link1 ()
  (let ((b1 (make-dynamixel-AX-12A-motor-body)))
    (send b1 :rotate pi/2 :z)
    (send b1 :rotate -pi/2 :y)
    (let ((bs (list b1)))
      (dolist (b (cdr bs)) (send (car bs) :assoc b))
      (let ((bl (instance bodyset-link
                          :init (make-cascoords)
                          :bodies (list b1)
                          :name
                          :arm-link1)))
        (send bl :put :joint-coords
              (make-cascoords :coords
                              (send (send (send (send (send (car bs) :get :joint-coords) :copy-worldcoords ) :locate #f(0 0 25)) :rotate pi/2 :z) :rotate pi :x)))
        (send bl :assoc (send bl :get :joint-coords))
        bl))))

(defun make-robot-arm-link2 ()
  (let ((b1 (make-dynamixel-AX-12A-frame2-body)))
    (let ((bl (instance bodyset-link
                        :init (make-cascoords)
                        :bodies (list b1) :name :arm-link2)))
      (send bl :put :joint-coords
            (make-cascoords :coords
                            (send (send b1 :copy-worldcoords) :locate #f(0 0 0))))
      (send bl :assoc (send bl :get :joint-coords))
      bl)))

(defun make-robot-arm-link3 ()
  (let ((b1s (make-dynamixel-AX-12A-motor-unit-bodies :use-frame1 (list :bottom)))
        (b2 (make-dynamixel-AX-12A-frame2-body)))
    (let ((bs (append (mapcar #'cadr b1s) (list b2))))
      ;; (car bs) is servo model
      (dolist (b (cdr bs)) (send (car bs) :assoc b))
      (send (car bs) :rotate pi/2 :x)
      (send b2 :rotate pi :z)
      (send b2 :rotate pi/2 :x)
      (send b2 :locate #f(0 0 -70))
      (let ((bl (instance bodyset-link
                          :init (make-cascoords)
                          :bodies bs :name :arm-link3)))
        (send bl :put :joint-coords
              (make-cascoords :coords (send (send (send (send (car bs) :copy-worldcoords) :locate #f(0 -80 0)) :rotate -pi/2 :y) :rotate 0 :z)))
        (send bl :assoc (send bl :get :joint-coords))
        bl))))

(defun make-robot-arm-link4 ()
  (let ((b1 (make-dynamixel-AX-12A-motor-body)))
    (send b1 :rotate pi/2 :x)
    (let ((bs (list b1)))
      (dolist (b (cdr bs)) (send (car bs) :assoc b))
      (send (car bs) :rotate pi/2 :y)
      (send (car bs) :rotate -pi/2 :x :world)
      (let ((bl (instance bodyset-link :init (make-cascoords)
                          :bodies bs :name :arm-link4)))
        (send bl :put :joint-coords
              (make-cascoords :coords
               (send (send (send (send (car bs) :get :joint-coords) :copy-worldcoords) :rotate -pi/2 :y) :locate #f(20 0 0))))
        (send bl :assoc (send bl :get :joint-coords))
        bl))))


;; root-link
(defun make-robot-leg-root-link ()
  (let ((b1 (make-dynamixel-AX-12A-motor-body)))
    (let ((bs (list b1)))
      (dolist (b (cdr bs)) (send (car bs) :assoc b))
      (send (car bs) :rotate pi/2 :y)
      (send (car bs) :rotate -pi/2 :x :world)
      (let ((bl (instance bodyset-link :init (make-cascoords)
                          :bodies bs :name :root-link)))
        bl))))

; ;; link1 :
(defun make-robot-leg-link1 ()
  (let ((b1s (make-dynamixel-AX-12A-motor-unit-bodies :use-frame1 (list :bottom)))
        (b2 (make-dynamixel-AX-12A-frame2-body)))
    (let ((bs (append (mapcar #'cadr b1s) (list b2))))
      ;; (car bs) is servo model
      (dolist (b (cdr bs)) (send (car bs) :assoc b))
      (send (car bs) :rotate pi/2 :x)
      (send (car bs) :rotate pi/2 :y)
      (send (car bs) :rotate -pi/2 :z)
      (send (car bs) :rotate -pi/2 :z :world)
      (send (car bs) :rotate pi :y :world)
      (send (car bs) :locate #f(0 0 40))
      (send b2 :rotate pi :z)
      (send b2 :rotate pi/2 :x)
      (send b2 :locate #f(0 -40 -5))
      (let ((bl (instance bodyset-link
                          :init (make-cascoords)
                          :bodies bs :name :leg-link1)))
        bl))))

;; link2 :
(defun make-robot-leg-link2 ()
  (let ((b1 (make-dynamixel-AX-12A-motor-body)))
    (let ((bs (list b1)))
      (dolist (b (cdr bs)) (send (car bs) :assoc b))
      (send (car bs) :rotate pi/2 :y)
      (send (car bs) :rotate pi :z)
      (send (car bs) :locate #f(0 0 30))
      (send (car bs) :rotate -pi/2 :x :world)
      (send (car bs) :rotate pi/2 :y :world)
      (let ((bl (instance bodyset-link :init (make-cascoords)
                          :bodies bs :name :leg-link2)))
        bl))))

;; link3 : frame2
(defun make-robot-leg-link3 ()
  (let* ((b (make-dynamixel-AX-12A-frame2-body))
         (b1s (make-dynamixel-AX-12A-motor-unit-bodies :use-frame1 (list :bottom)))
         (motor (cadr (assoc :motor b1s)))
         (bottom (cadr (assoc :bottom b1s))))
    (send b :rotate -pi/2 :y)
    (send b :rotate pi :x)
    (send b :rotate pi/2 :z)
    (send b :locate #f(0 20 30))
    (send b :translate (v- (send b :worldpos) (send (send b :get :attach-coords) :worldpos)) :world)

    ;;(send b :assoc (cadr (assoc :motor b1s)))
    ;;(send b :assoc (cadr (assoc :bottom b1s)))
    (send b :assoc motor)
    (send b :assoc bottom)
    (send motor :assoc bottom)

    (send motor :rotate -pi/2 :z)

    (send motor :locate #f(0 70 -20))

    (let ((bl (instance bodyset-link :init (make-cascoords)
                        :bodies (append (list b) (mapcar #'cadr b1s)) :name :leg-link3)))
      bl)))

;; link4 : motor+frame1-side+offset+motor
(defun make-robot-leg-link4 ()
  (let ((c1 (make-cube 5 20 100))
        (c2 (make-cube 5 20 100)))
    (send c1 :put :face-color :slategray)
    (send c2 :put :face-color :slategray)
    (send c1 :assoc c2)

    (send c2 :locate #f(45 0 0))
    (send c1 :locate #f(0 30 0))
    (send c1 :rotate pi/2 :x)

    (let ((bs (list c1 c2)))
      ;; (car bs) is servo model
      (let ((bl (instance bodyset-link
                          :init (make-cascoords)
                          :bodies bs :name :leg-link4)))
        bl))))

;; link5 :
(defun make-robot-leg-link5 ()
  (let ((b1s (make-dynamixel-AX-12A-motor-body)))
    (send b1s :rotate pi/2 :z)
    (send b1s :rotate pi/2 :y)
    (let ((bl (instance bodyset-link :init (make-cascoords)
                        :bodies (list b1s) :name :leg-link5)))
      bl)))

;; link6 :
(defun make-robot-leg-link6 ()
  (let ((b1s (make-dynamixel-AX-12A-motor-body))
        (b (make-dynamixel-AX-12A-frame2-body))
        (c (make-cube 5 60 100)))
    (send b1s :locate #f(-45 0 0))
    (send b1s :rotate pi/2 :y)

    (send b1s :assoc b)
    (send b :rotate pi/2 :z)
    (send b :rotate pi/2 :y)
    (send b :locate #f(0 0 0))

    (send b1s :assoc c)
    (send c :put :face-colo :slategray)
    (send c :rotate pi/2 :z)
    (send c :rotate pi/2 :x)
    (send c :locate #f(30 0 0))

    (instance bodyset-link :init (make-cascoords)
              :bodies (list b1s b c) :name :leg-link6)))

(defclass iorobot
  :super robot-model
  :slots (jcr0 jcr1 jcr2 jcr3 jcr4 jcr5 jcr6
          jcl0 jcl1 jcl2 jcl3 jcl4 jcl5 jcl6
          joint-rarm0 joint-rarm1 joint-rarm2
          joint-larm0 joint-larm1 joint-larm2
          joint-head0))
(defmethod iorobot
  (:init
   (&rest args
    &key (name "iorobot"))
   (send-super* :init :name name args)
   ;; 1. make links links and assoc all links
   (let ((aroot-link (send self :make-root-link)))
     ;; leg setting
     (setq right-leg-root-link (send self :make-leg-root-link))
     (setq left-leg-root-link (send self :make-leg-root-link))
     (setq rleg (send self :make-leg-links :rleg))
     (setq lleg (send self :make-leg-links :lleg))

     (send left-leg-root-link :translate (float-vector 15 40 20) :world)
     (send right-leg-root-link :translate (float-vector 15 -40 20) :world)
     (send left-leg-root-link :rotate -pi/2 :y)
     (send right-leg-root-link :rotate -pi/2 :y)
     (send left-leg-root-link :rotate pi :z)
     (send right-leg-root-link :rotate pi :z)

     ;; head parts
     (setq head (send self :make-head-links))
     (setq head-root-link (car head))
     (send head-root-link :move-coords (send aroot-link :get :joint-coords) (send head-root-link :copy-worldcoords))
     (send (send (send (send head-root-link :translate (float-vector 10 0 150) :world) :rotate pi/2 :x) :rotate -pi/2 :z) :rotate pi :y)

     ;; body torso parts
     (setq torso (send self :make-torso-link))
     (send torso :translate (float-vector 0 0 70) :world)

     ;; arm setting
     ;; right-arm
     (setq rarm (send self :make-arm-links))
     (setq right-arm-root-link (car rarm))
     (send right-arm-root-link :move-coords (send aroot-link :get :joint-coords) (send right-arm-root-link :copy-worldcoords))
     (send (send right-arm-root-link :translate (float-vector 0 -35 150) :world) :rotate pi :x)

     ;; left-arm
     (setq larm (send self :make-arm-links))
     (setq left-arm-root-link (car larm))
     (send left-arm-root-link :move-coords (send aroot-link :get :joint-coords) (send left-arm-root-link :copy-worldcoords))
     (send left-arm-root-link :translate (float-vector 0 35 150) :world)

     ;; 2. assoc links
     ;;    Root link should be associated with "self".
     (send self :assoc aroot-link)
     (send self :assoc torso)
     (send aroot-link :assoc right-leg-root-link)
     (send aroot-link :assoc left-leg-root-link)
     (send right-leg-root-link :assoc (car rleg))
     (send left-leg-root-link :assoc (car lleg))
     (send aroot-link :assoc left-arm-root-link)
     (send aroot-link :assoc right-arm-root-link)
     (send aroot-link :assoc head-root-link)

     (send (car lleg):translate (float-vector 0 80 0) :world)

     ;; 3. make all joints
     ;;    Before making joints, you should :assoc all links.

     ;; head
     (setq joint-head0 (instance rotational-joint
                         :init :parent-link head-root-link
                         :child-link (elt head 1)
                         :name "head_joint1"
                         :axis :z
                         :min -90
                         :max 90))

     ;; right-leg
     (setq jcr0 (instance rotational-joint
                         :init :parent-link right-leg-root-link
                         :child-link (elt rleg 0)
                         :name "rleg_joint1"
                         :axis :x
                         :min -60
                         :max 30))
     (setq jcr1 (instance rotational-joint
                         :init :parent-link (elt rleg 0)
                         :child-link (elt rleg 1)
                         :name "rleg_joint2"
                         :axis :y
                         :min -10
                         :max 90))
     (setq jcr2 (instance rotational-joint
                         :init :parent-link (elt rleg 1)
                         :child-link (elt rleg 2)
                         :name "rleg_joint3"
                         :axis :z
                         :min -70
                         :max 90))
     (setq jcr3 (instance rotational-joint
                         :init :parent-link (elt rleg 2)
                         :child-link (elt rleg 3)
                         :name "rleg_joint4"
                         :axis :x
                         :min -135
                         :max 135))
     (setq jcr4 (instance rotational-joint
                         :init :parent-link (elt rleg 3)
                         :child-link (elt rleg 4)
                         :name "rleg_joint5"
                         :axis :y
                         :min -90
                         :max 45))
     (setq jcr5 (instance rotational-joint
                         :init :parent-link (elt rleg 4)
                         :child-link (elt rleg 5)
                         :name "rleg_joint6"
                         :axis :x
                         :min -30
                         :max 30))

     ;; left-leg
     (setq jcl0 (instance rotational-joint
                         :init :parent-link left-leg-root-link
                         :child-link (elt lleg 0)
                         :name "lleg_joint1"
                         :axis :x
                         :min -30
                         :max 60))
     (setq jcl1 (instance rotational-joint
                         :init :parent-link (elt lleg 0)
                         :child-link (elt lleg 1)
                         :name "lleg_joint2"
                         :axis :y
                         :min -90
                         :max 10))
     (setq jcl2 (instance rotational-joint
                         :init :parent-link (elt lleg 1)
                         :child-link (elt lleg 2)
                         :name "lleg_joint3"
                         :axis :z
                         :min -70
                         :max 90))
     (setq jcl3 (instance rotational-joint
                         :init :parent-link (elt lleg 2)
                         :child-link (elt lleg 3)
                         :name "lleg_joint4"
                         :axis :x
                         :min -135
                         :max 135))
     (setq jcl4 (instance rotational-joint
                         :init :parent-link (elt lleg 3)
                         :child-link (elt lleg 4)
                         :name "lleg_joint5"
                         :axis :y
                         :min -90
                         :max 45))
     (setq jcl5 (instance rotational-joint
                         :init :parent-link (elt lleg 4)
                         :child-link (elt lleg 5)
                         :name "lleg_joint6"
                         :axis :x
                         :min -30
                         :max 30))

     ;; joint-rarm setting
     (setq joint-rarm0 (instance rotational-joint
                         :init :parent-link (elt rarm 0)
                         :child-link (elt rarm 1)
                         :name "rarm_joint1"
                         :axis :z
                         :min -180
                         :max 180))

     (setq joint-rarm1 (instance rotational-joint
                         :init :parent-link (elt rarm 1)
                         :child-link (elt rarm 2)
                         :name "rarm_joint2"
                         :axis :y
                         :min -90
                         :max 90))

     (setq joint-rarm2 (instance rotational-joint
                         :init :parent-link (elt rarm 2)
                         :child-link (elt rarm 3)
                         :name "rarm_joint3"
                         :axis :x
                         :min -90
                         :max 90))

     (setq joint-larm0 (instance rotational-joint
                         :init :parent-link (elt larm 0)
                         :child-link (elt larm 1)
                         :name "larm_joint1"
                         :axis :z
                         :min -180
                         :max 180))

     (setq joint-larm1 (instance rotational-joint
                         :init :parent-link (elt larm 1)
                         :child-link (elt larm 2)
                         :name "larm_joint2"
                         :axis :y
                         :min -90
                         :max 90))

     (setq joint-larm2 (instance rotational-joint
                         :init :parent-link (elt larm 2)
                         :child-link (elt larm 3)
                         :name "larm_joint3"
                         :axis :x
                         :min -90
                         :max 90))

     ;; 4. define slots for robot class
     ;; links and joint-list for cascaded-link.
     (setq links (append (list
                          aroot-link left-leg-root-link right-leg-root-link torso)
                         rleg lleg rarm larm head))
     (setq joint-list (list jcr0 jcr1 jcr2 jcr3 jcr4 jcr5
                            jcl0 jcl1 jcl2 jcl3 jcl4 jcl5
                            joint-rarm0 joint-rarm1 joint-rarm2
                            joint-larm0 joint-larm1 joint-larm2
                            ;; joint-head0
			    ))
     ;;    These are for robot-model.
     (setq rleg-root-link (car rleg))
     (setq lleg-root-link (car lleg))

     ;;    end-coords
     (setq rarm-end-coords (make-cascoords :coords
                                           (send (send (elt rarm 3) :copy-worldcoords) :translate (float-vector 0 0 0))))
     (setq larm-end-coords (make-cascoords :coords
                                           (send (send (elt larm 3) :copy-worldcoords) :translate (float-vector 0 0 0))))
     (setq rleg-end-coords (make-cascoords :coords
                                           (send (send (send (elt rleg 5) :copy-worldcoords) :translate (float-vector 0 30 0)) :rotate pi/2 :x)))
     (send (elt rleg 5) :assoc rleg-end-coords)
     (setq lleg-end-coords (make-cascoords :coords
                                           (send (send (send (elt lleg 5) :copy-worldcoords) :translate (float-vector 0 30 0)) :rotate pi/2 :x)))
     (send (elt lleg 5) :assoc lleg-end-coords)

     ;; set max torques
     (dolist (l (list aroot-link torso head-root-link))
       (let* ((valid-bodies (remove-if #'(lambda (x)
                                           (and (> (send x :volume) 0) (< (send x :volume) 0))) ;; nan check
                                       (send l :bodies))))
         (send l :centroid
               (if (= (length valid-bodies) 1)
                   (send (car valid-bodies) :centroid)
                 (scale (/ 1.0 (reduce #'+ (mapcar #'(lambda (x) (send x :volume)) valid-bodies)))
                        (reduce #'v+ (mapcar #'(lambda (x) (scale (send x :volume) (send x :centroid))) valid-bodies)))))
         ))
     (send-all (send self :joint-list) :max-joint-torque 7.5) ;; [Nm]

     ;; 5. call :init-ending after defining links and joint-list and return "self"
     (send self :init-ending)
     self))
  ;; links
  ;; set to aroot-link
  (:make-root-link ()
   (make-robot-root-link))
  (:make-torso-link ()
        (make-robot-torso-link)
        )
  (:make-head-links ()
   (let ((ln
          (list (make-robot-head-link1)
                (make-robot-head-link2))))
     (dotimes (i (1- (length ln)))
       (send (elt ln (1+ i)) :move-coords
             (send (elt ln i) :get :joint-coords)
             (send (elt ln (1+ i)) :copy-worldcoords)))
     (dotimes (i (1- (length ln)))
       (send (elt ln i) :assoc (elt ln (1+ i))))
     ln))
  (:make-arm-links ()
   (let ((ln
          (list (make-robot-arm-link1)
                (make-robot-arm-link2)
                (make-robot-arm-link3)
                (make-robot-arm-link4))))
     (dotimes (i (1- (length ln)))
       (send (elt ln (1+ i)) :move-coords
             (send (elt ln i) :get :joint-coords)
             (send (elt ln (1+ i)) :copy-worldcoords)))
     (dotimes (i (1- (length ln)))
       (send (elt ln i) :assoc (elt ln (1+ i))))
     ln))
  (:make-leg-root-link ()
     (make-robot-leg-root-link))
  (:make-leg-links
   (l/r)
   (let* ((bl1 (make-robot-leg-link1))
          (bl2 (make-robot-leg-link2))
          (bl3 (make-robot-leg-link3))
          (bl4 (make-robot-leg-link4))
          (bl5 (make-robot-leg-link5))
          (bl6 (make-robot-leg-link6)))
     (send bl6 :translate #f(0 -40 0))
     (send bl6 :rotate pi :z)

     (send bl5 :rotate pi/2 :z)
     (send bl5 :rotate -pi/2 :x)
     (send bl5 :translate #f(-50 0 0))
     (send bl5 :assoc bl6)
     (send bl5 :rotate -pi/2 :z)
     (send bl5 :rotate pi :x)

     (send bl5 :translate #f(-230 -15 0))
     (send bl4 :translate #f(0 -60 -150))
     (send bl4 :rotate pi/2 :z)
     (send bl4 :rotate -pi/2 :x)
     (send bl4 :assoc bl5)

     (send bl3 :translate #f(0 -20 -70))
     (send bl3 :rotate pi/2 :y)
     (send bl3 :rotate -pi/2 :x)
     (send bl3 :assoc bl4)

     (send bl2 :translate #f(0 -40 -40))
     (send bl2 :rotate pi/2 :y)
     (send bl2 :rotate -pi/2 :x)
     (send bl2 :assoc bl3)

     (send bl1 :translate #f(0 -40 -20))
     (send bl1 :rotate pi/2 :y)
     (send bl1 :rotate pi/2 :x)
     (send bl1 :assoc bl2)
     (list bl1 bl2 bl3 bl4 bl5 bl6)))
  ;; joints
  (:head_joint1 () joint-head0)

  (:rarm_joint1 () joint-rarm0)
  (:rarm_joint2 () joint-rarm1)
  (:rarm_joint3 () joint-rarm2)

  (:larm_joint1 () joint-larm0)
  (:larm_joint2 () joint-larm1)
  (:larm_joint3 () joint-larm2)

  (:rleg_joint1 () jcr0)
  (:rleg_joint2 () jcr1)
  (:rleg_joint3 () jcr2)
  (:rleg_joint4 () jcr3)
  (:rleg_joint5 () jcr4)
  (:rleg_joint6 () jcr5)

  (:lleg_joint1 () jcl0)
  (:lleg_joint2 () jcl1)
  (:lleg_joint3 () jcl2)
  (:lleg_joint4 () jcl3)
  (:lleg_joint5 () jcl4)
  (:lleg_joint6 () jcl5)

  ;;
  (:joint_head1 () joint-head0)

  (:joint_rarm1 () joint-rarm0)
  (:joint_rarm2 () joint-rarm1)
  (:joint_rarm3 () joint-rarm2)

  (:joint_larm1 () joint-larm0)
  (:joint_larm2 () joint-larm1)
  (:joint_larm3 () joint-larm2)

  (:joint_rleg1 () jcr0)
  (:joint_rleg2 () jcr1)
  (:joint_rleg3 () jcr2)
  (:joint_rleg4 () jcr3)
  (:joint_rleg5 () jcr4)
  (:joint_rleg6 () jcr5)

  (:joint_lleg1 () jcl0)
  (:joint_lleg2 () jcl1)
  (:joint_lleg3 () jcl2)
  (:joint_lleg4 () jcl3)
  (:joint_lleg5 () jcl4)
  (:joint_lleg6 () jcl5)

  ;; limbs
  (:rarm (&rest args)
         (unless args (setq args (list nil))) (send* self :limb :rarm args))
  (:larm (&rest args)
         (unless args (setq args (list nil))) (send* self :limb :larm args))
  (:rleg (&rest args)
        (unless args (setq args (list nil))) (send* self :limb :rleg args))
  (:lleg (&rest args)
        (unless args (setq args (list nil))) (send* self :limb :lleg args))
  ;; poses
  (:init-pose
   ()
   ;;(send self :angle-vector (instantiate float-vector (send self :calc-target-joint-dimension (cdr (send self :links))))))
   (send self :angle-vector (float-vector 0.0 0.0 0.0 0.0 0.0 0.0
                                          0.0 0.0 0.0 0.0 0.0 0.0
                                          0.0 0.0 0.0
                                          0.0 0.0 0.0
                                          0.0)))
  ;; (:reset-pose
  ;;  ()
  ;;  (send self :angle-vector (float-vector 0.0 0.0 0.0 0.0 0.0 0.0
  ;;                                         0.0 0.0 0.0 0.0 0.0 0.0
  ;;                                         0.0 60.0 -30.0
  ;;                                         0.0 60.0 -30.0
  ;;                                         0.0)))
  (:reset-pose
   ()
   (send self :angle-vector (float-vector 0 0 -30 60 30 0
                                          0 0 -30 60 30 0
                                          0.0 60.0 -30.0
                                          0.0 60.0 -30.0
                                          0.0)))
  (:bend-leg ()
	 (send self :angle-vector (float-vector 0 0 -60 90 30 0
                                            0 0 -60 90 30 0
                                            0 0 0
                                            0 0 0
                                            0)))
  (:init-test ()
    (send self :angle-vector (float-vector 0 10 -10 20 10 10
                                           0 -10 -10 20 10 -10
                                           0 0 0
                                           0 0 0
                                           0)))
  )

(defun make-iorobot ()
  (setq *iorobot* (instance iorobot :init)))

(setq *ri* (make-iorobot))
(objects (list *ri*))
