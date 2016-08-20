#!/bin/sh
# Initially written by Edwin Smith
# v1.0 - Initial Public release

#Warning that you use this at your own risk.
echo "No Warranty given or implied. Use at your own risk."

# Grab Initial Info
cpuTemp=$(getsysinfo cputmp | awk '{print $1;}')
fanSpeed1=$(getsysinfo sysfan 1 | awk '{print $1;}')
fanSpeed2=$(getsysinfo sysfan 2 | awk '{print $1;}')

# Check how your own fans are wired up by setting one fan only to max speed
# If you have a 4 Bay model you won't have a second fan
#
# hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=0,mode=7
#
# You can then setup the fans so you ramp up the fan on the CPU side more
# this will help reduce the noise of your fans while keeping your CPU
# as cool as possible
#
# obj_index=0 HHD Side Fan
# obj_index=1 CPU Side Fan

# Define 8 modes based on CPU temperature
#
# With TS870 using i7 3770S upgrade I usually idle at 42c at
# fan speed 2 using Noctua NF-F12 3000rpm PWM fans
FanSpeed_1=40
FanSpeed_2=45
FanSpeed_3=48
FanSpeed_4=51
FanSpeed_5=54
FanSpeed_6=57
FanSpeed_7=60
FanSpeed_8=63

echo "CPU Temp  :     $cpuTemp C"
echo "Fan1 Speed:     $fanSpeed1 RPM"
echo "Fan2 Speed:     $fanSpeed2 RPM"

# Enter Loop
while [ 1 ]
do
#Update Current Status
cpuTemp=$(getsysinfo cputmp | awk '{print $1;}')
fanSpeed1=$(getsysinfo sysfan 1 | awk '{print $1;}')
fanSpeed2=$(getsysinfo sysfan 2 | awk '{print $1;}') 
#Display Date Stamp
echo "=========="
echo "=========="
echo "$(date)"
echo "CPU Temp  :     $cpuTemp C"
echo "Fan1 Speed:     $fanSpeed1 RPM"
echo "Fan2 Speed:     $fanSpeed2 RPM"
echo " "
echo "Setting Fan speeds..."

# The mode= at the endof the fan speeds are the speed the fan is running at 0-7
# The obj_index= is the fan on 8 bay QNAPs you'll have 2 - 0 & 1
# You should check the correct fans are set below by checking which fan does what
# using the command example at the top of this script. If you have a 4 bay QNAP you'll
# only have one fan.

# Fan Speed 1 (Reduced Mode)
if (( cpuTemp < FanSpeed_1 )); then
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=0,mode=1
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=1,mode=2
fi

# Fan Speed 1
if (( cpuTemp > FanSpeed_1 )); then
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=0,mode=2
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=1,mode=2
fi

# Fan Speed 2
if (( cpuTemp > FanSpeed_2 )); then
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=0,mode=2
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=1,mode=2
fi

# Fan Speed 3
if (( cpuTemp > FanSpeed_3 )); then
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=0,mode=3
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=1,mode=3
fi

# Fan Speed 4
if (( cpuTemp > FanSpeed_4 )); then
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=0,mode=3
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=1,mode=4
fi

# Fan Speed 5
if (( cpuTemp > FanSpeed_5 )); then
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=0,mode=3
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=1,mode=5
fi

# Fan Speed 6
if (( cpuTemp > FanSpeed_6 )); then
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=0,mode=4
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=1,mode=6
fi

# Fan Speed 7
if (( cpuTemp > FanSpeed_7 )); then
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=0,mode=4
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=1,mode=7
fi

# Fan Speed 8
if (( cpuTemp > FanSpeed_8 )); then
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=0,mode=7
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=1,mode=7
fi

# Check CPU temperature every 15 seconds
sleep 15

done