#!/usr/bin/env python
from std_msgs.msg import Float32
import rospy
import threading
rospy.init_node("rviz_timer")

clock_pub = rospy.Publisher("jishupro_timer", Float32)
rate = 2
r = rospy.Rate(rate)

counter = 180
def time_counter():
  global counter
  counter = counter - 1
  msg = Float32()
  msg.data = counter
  clock_pub.publish(msg)
  if counter != 0:
    time = threading.Timer(1.0, time_counter)
    time.start()

time = threading.Timer(1.0, time_counter)
time.start()
