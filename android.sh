============DROZER=============
adb forward tcp:31415 tcp:31415
adb forward --remove-all
=============BURP==============
adb shell settings put global http_proxy 127.0.0.1:8080
adb reverse tcp:8080 tcp:8080
adb reverse --remove-all
===============================
