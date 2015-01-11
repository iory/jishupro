# jishupro
自主プロジェクト用

```
mkdir -p ~/catkin_ws/src
cd ~/catkin_ws/src
catkin_init_workspace
git clone https://github.com/iory/jishupro.git
cd ../
catkin_make
source devel/setup.bash
roscd jishupro/euslisp
roseus robot-interface.l
```
