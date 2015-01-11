;; Dynamixel AX-12A
;;   http://www.besttechnology.co.jp/modules/knowledge/?BTX030B%20Dynamixel%20AX-12A
(defun make-dynamixel-AX-12A-motor-body ()
  (let ((b1 (make-cube 26 11.5 32))
        (b2 (make-cube 32 38.5 32))
        (b3 (make-cylinder (/ 22 2.0) 5))
        (b4 (make-cylinder (/ 10 2.0) 3))
        )
    (send b1 :translate (float-vector 0 (/ 11.5 2.0) 0))
    (send b2 :translate (float-vector 0 (/ 38.5 -2.0) 0))
    (send b3 :translate (float-vector 0 0 (/ 32 2.0)))
    (send b4 :translate (float-vector 0 0 (- (+ (/ 32 2.0) 3))))
    (let ((b (body+ b1 b2 b3 b4)))
      (send b :put :face-color :gray10)
      (send b :put :attach-coords (make-cascoords :pos (float-vector 0 -13.5 -16)))
      (send b :assoc (send b :get :attach-coords))
      (send b :put :joint-coords (make-cascoords :pos (float-vector 0 0 (+ 16 5))))
      (send b :assoc (send b :get :joint-coords))
      b)))

;; Small frame parts for Dynamixel AX-12A
;;  F3 in http://www.besttechnology.co.jp/modules/knowledge/?BTX030B%20Dynamixel%20AX-12A
(defun make-dynamixel-AX-12A-frame1-body ()
  (let ((b1 (make-cube 25 32 4))
        (b2 (make-cube 25 3.1 9))
        (b3 (make-cube 25 3.1 9)))
    (send b1 :translate (float-vector 0 0 3.5))
    (send b2 :translate (float-vector 0 17.55 1.0))
    (send b3 :translate (float-vector 0 -17.55 1.0))
    (let ((b (body+ b1 b2 b3)))
      (send b :put :face-color :slategray)
      (send b :put :attach-coords (make-cascoords :pos (float-vector 0 0 5.5)))
      (send b :assoc (send b :get :attach-coords))
      b)))

;; Large frame parts for Dynamixel AX-12A
;;  F2 in http://www.besttechnology.co.jp/modules/knowledge/?BTX030B%20Dynamixel%20AX-12A
(defun make-dynamixel-AX-12A-frame2-body ()
  (let ((b1 (make-cube 24.8 41.8 7))
        (b2 (make-cube 24.8 3.2 37.5))
        (b3 (make-cube 24.8 3.2 37.5)))
    (send b1 :translate (float-vector 0 0 23))
    (send b2 :translate (float-vector 0 22.5 7.75))
    (send b3 :translate (float-vector 0 -22.5 7.75))
    (let ((b (body+ b1 b2 b3)))
      (send b :put :face-color :slategray)
      (send b :put :attach-coords (make-cascoords :pos (float-vector 0 0 26.5) :rpy (list 0 pi 0)))
      (send b :assoc (send b :get :attach-coords))
      b)))

;; gripper parts
(defun make-dxl-7dof-arm-gripper-body ()
  (let ((b1 (make-prism
             (list (float-vector 0 80 0)
                   (float-vector 5 80 0)
                   (float-vector 15 35 0)
                   (float-vector 15 0 0)
                   (float-vector 0 0 0)
                   )
             40))
        (b2 (make-cube 50 100 38)))
    (send b2 :translate (float-vector (+ 25 1) (- 50 1) (+ 1 (/ 38 2.0))))
    (let ((b (body- b1 b2)))
      (send b :translate-vertices (float-vector 0 -13 -20))
      (send b :put :face-color :silver)
      b)))

;; base parts
(defun make-dxl-7dof-arm-base-body ()
  (let ((b1 (make-cube 41 30 5))
        (b2 (make-cube 5 30 40)))
    (send b1 :translate (float-vector -7.5 0 2.5))
    (send b2 :translate (float-vector -25.5 0 20))
    (let ((b (body+ b1 b2)))
      (send b :put :face-color :silver)
      (send b :put :attach-coords (make-cascoords :pos (float-vector -28 0 21.5) :rpy (list 0 pi/2 0)))
      (send b :assoc (send b :get :attach-coords))
      b)))

;; motor+frame1
(defun make-dynamixel-AX-12A-motor-unit-bodies
  (&key (use-frame1 (list :bottom :left)))
  (let* ((motor-body (make-dynamixel-AX-12A-motor-body))
        (frame1-bodies
         (mapcar #'(lambda (x)
                     (let ((b (make-dynamixel-AX-12A-frame1-body)))
                       (case x
                         (:bottom
                          (send b :rotate pi/2 :x)
                          (send b :translate (float-vector 0 0 36)))
                         (:left
                          (send b :rotate pi/2 :x)
                          (send b :rotate -pi/2 :y)
                          (send b :translate (float-vector (/ 27 -2.0) -14.5 0) :world))
                         (:right
                          (send b :rotate pi/2 :x)
                          (send b :rotate pi/2 :y)
                          (send b :translate (float-vector (/ 27 2.0) -14.5 0) :world))
                         (t ))
                       (list x b)))
                 use-frame1))
        (unit-bodies
         (append (list (list :motor motor-body))
                 frame1-bodies)))
    (dolist (b (cdr unit-bodies))
      (send (cadr (car unit-bodies)) :assoc (cadr b)))
    unit-bodies))
