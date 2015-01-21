#!/usr/bin/env python
try:
  from jsk_rviz_plugins.msg import *
except:
  import roslib;roslib.load_manifest("jsk_rviz_plugins")
  from jsk_rviz_plurgins.msg import *

from std_msgs.msg import ColorRGBA, Float32
import rospy
import math
import threading
rospy.init_node("rviz_timer")

text_pub = rospy.Publisher("jishupro_timer", OverlayText)
rate = 2
r = rospy.Rate(rate)

counter = 180
def time_counter():
  global counter
  counter = counter - 1
  text = OverlayText()
  text.width = 400
  text.height = 600
  text.left = 10
  text.top = 10
  text.text_size = 12
  text.line_width = 2
  text.font = "DejaVu Sans Mono"
  text.text = str(counter)
  text.fg_color = ColorRGBA(25 / 255.0, 1.0, 240.0 / 255.0, 1.0)
  text.bg_color = ColorRGBA(0.0, 0.0, 0.0, 0.2)
  text_pub.publish(text)
  if counter != 0:
    time = threading.Timer(1.0, time_counter)
    time.start()

time = threading.Timer(1.0, time_counter)

time.start()
