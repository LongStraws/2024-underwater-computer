CAMERA1= "/dev/video1"
CAMERA2= "/dev/video2"
CAMERA3= "/dev/video3"
WIDTH=1920
HEIGHT=1080

#to topside (non-wsl)
gst-launch-1.0 -v v4l2src device=$CAMERA1 ! video/x-h264,width=$WIDTH,height=$HEIGHT ! h264parse ! queue ! rtph264pay config-interval=10 pt=96 ! udpsink host=192.168.137.1 port=5601 sync=false &
gst-launch-1.0 -v v4l2src device=$CAMERA2 ! video/x-h264,width=$WIDTH,height=$HEIGHT ! h264parse ! queue ! rtph264pay config-interval=10 pt=96 ! udpsink host=192.168.137.1 port=5602 sync=false &
gst-launch-1.0 -v v4l2src device=$CAMERA3 ! video/x-h264,width=$WIDTH,height=$HEIGHT ! h264parse ! queue ! rtph264pay config-interval=10 pt=96 ! udpsink host=192.168.137.1 port=5600 sync=false &

#broadcast
gst-launch-1.0 -v v4l2src device=$CAMERA1 ! video/x-h264,width=$WIDTH,height=$HEIGHT ! h264parse ! queue ! rtph264pay config-interval=10 pt=96 ! udpsink host=192.168.137.255 port=5601 sync=false
gst-launch-1.0 -v v4l2src device=$CAMERA2 ! video/x-h264,width=$WIDTH,height=$HEIGHT ! h264parse ! queue ! rtph264pay config-interval=10 pt=96 ! udpsink host=192.168.137.255 port=5602 sync=false
gst-launch-1.0 -v v4l2src device=$CAMERA3 ! video/x-h264,width=$WIDTH,height=$HEIGHT ! h264parse ! queue ! rtph264pay config-interval=10 pt=96 ! udpsink host=192.168.137.255 port=5600 sync=false