#!/bin/sh 
# Initially written by Edwin Smith
# v1.0 - Initial Public release
# v1.1 - Modified by Tim Norton - 21/08/2016
# v1.2 - Modified by Edwin Smith- 23/08/2016

#Warning that you use this at your own risk.
echo "====================================================="
echo "No Warranty given or implied. Use at your own risk.  "
echo "====================================================="
echo "You are running FanControl which will change your    "
echo "system fan speeds based on cpu temperature. Currently"
echo "only supports QNAP TS-870 and TS-853A models.        "

# Check how your own fans are wired up by setting one fan only to max speed
# If you have a 4 Bay model you won't have a second fan
#
# hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=0,mode=7
# i.e set first fan(0) to max(7)
#
# enc_sys_id is always root unless you have an enclosure which this script does not cover!!
#
# With Edwin's TS870 - You can then setup the fans so you ramp up the fan on the CPU side more
# this will help reduce the noise of your fans while keeping your CPU as cool as possible.
#
# obj_index=0 HHD Side Fan
# obj_index=1 CPU Side Fan
#
# With Tim's 853a - the fans appear to work together i.e. changing one fan speed changes the other
# so having differnt speeds per fan does not appear possible. The fans are replacements so the stock
# fans my behave differntly.

# With TS870 using i7 3770S upgrade I usually idle at 42c at
# fan speed 2 using Noctua NF-F12 3000rpm PWM fans
#

# Grab Initial Info
sysModel=$(getsysinfo model | awk '{print $1;}')   #What QNAP Model do we have

# Set Supported Flag to False (Default)
enableFanControl=0

# Define 7 step modes based on CPU temperature for fans
# You will need to define your own step points to suit your
# fans and NAS.Also make sure the sysModel variable is set correctly
# in the if statement below.

if [ "$sysModel" = "TS-870" ]
then
enableFanControl=1
cpuStepTemp=( 43 45 47 49 51 54 58 )      # TS-870 temps at which to change fan speed
cpuStepFan1=( 1 2 2 3 4 4 7 )             # Fan modes for Fan1 to match cpu temp step changes
cpuStepFan2=( 2 2 3 4 5 6 7 )             # Fan modes for Fan2 to match cpu temp step changes
fi

if [ "$sysModel" = "TS-853A" ]
then
enableFanControl=1
cpuStepTemp=( 30 32 34 38 40 42 44 )      # TS-853A temps at which to change fan speed
cpuStepFan1=( 1 2 3 4 5 6 7 )             # Fan modes for Fan1 to match cpu temp step changes
cpuStepFan2=( 1 2 3 4 5 6 7 )             # Fan modes for Fan2 to match cpu temp step changes
fi

# Check if your machine is listed as supported if not don't run fanControl and
# output debug info instead.
echo "==================================================="
echo "Checking if your model is supported..."
echo "==================================================="
if (( $enableFanControl == 1 )); then
echo "==================================================="
echo "QNAP Model Supported  :     $sysModel"
echo "==================================================="
# Enter Loop
while [ 1 ]
do
#Update Current Status
hddNum=$(getsysinfo hdnum | awk '{print $1;}')    # How Many HDD/SSD do we have

for (( i=1; i <= hddNum; i++ ))                   # Get the HDD/SSD individual temps
do
hddTemp[$i]=$(getsysinfo hdtmp $i | awk '{print $1;}')
done

cpuTemp=$(getsysinfo cputmp | awk '{print $1;}')   # Whats the cpu temp
sysTemp=$(getsysinfo systmp | awk '{print $1;}')   # Whats the system temp

fanNum=$(getsysinfo sysfannum | awk '{print $1;}') # How many fans have we got?
if (( $fanNum != 2 ))     #assumes we do not have three fans!
then
fanSpeed[1]=$(getsysinfo sysfan 1 | awk '{print $1;}')
else
fanSpeed[1]=$(getsysinfo sysfan 1 | awk '{print $1;}')
fanSpeed[2]=$(getsysinfo sysfan 2 | awk '{print $1;}')
fi

#Display Info
echo "==================================================="
echo "$(date)"
echo "QNAP Model   :     $sysModel"
echo "CPU Temp     :     $cpuTemp C"
echo "System Temp  :     $sysTemp C"
echo "No. of Disks :     $hddNum"

for (( i=1; i <= hddNum; i++ ))  #print out HDD/SDD individual temps
do
echo "HDD $i        :     ${hddTemp[i]} C"
done

echo "No. of Fans  :     $fanNum"
if (( $fanNum != 2 ))      #assumes we do not have three fans!
then
echo "Fan1 Speed   :     ${fanSpeed[1]} RPM"
else
echo "Fan1 Speed   :     ${fanSpeed[1]} RPM"
echo "Fan2 Speed   :     ${fanSpeed[2]} RPM"
fi


# The mode= at the endof the fan speeds are the speed the fan are running at 1-7.
# Mode=0 is equivalent to mode=1
# The obj_index= is the fan on 8 bay QNAPs you'll have 2 - 0 & 1
# You should check the correct fans are set below by checking which fan does what
# using the command example at the top of this script. If you have a 4 bay QNAP you'll
# only have one fan which the script handles.

echo "==================================================="
echo "Checking for required Fan speed changes..."
echo "==================================================="

# Fan Step Speed 1 set fan speed to lowest level set in cpuStepTemp
if (( "$cpuTemp" < "${cpuStepTemp[0]}" ))
then
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=0,mode=${cpuStepFan1[0]}
echo "Setting Fan 1 to Mode ${cpuStepFan1[0]} as cpu temperature below ${cpuStepTemp[0]}"
	if (( $fanNum == 2 ))     #assumes we do not have three fans!
	then
	hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=1,mode=${cpuStepFan2[0]}
	echo "Setting Fan 2 to Mode ${cpuStepFan2[0]} as cpu temperature below ${cpuStepTemp[0]}"
	fi
fi

if (( "$cpuTemp" > "${cpuStepTemp[0]}" )) && (( "$cpuTemp" <= "${cpuStepTemp[1]}" ))
then
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=0,mode=${cpuStepFan1[1]}
echo "Setting Fan 1 to Mode ${cpuStepFan1[1]} as cpu temperature above ${cpuStepTemp[0]}"
	if (( $fanNum == 2 ))     #assumes we do not have three fans!
	then
	hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=1,mode=${cpuStepFan2[1]}
	echo "Setting Fan 2 to Mode ${cpuStepFan2[1]} as cpu temperature above ${cpuStepTemp[0]}"
	fi
fi

if (( "$cpuTemp" > "${cpuStepTemp[1]}" )) && (( "$cpuTemp" <= "${cpuStepTemp[2]}" ))
then
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=0,mode=${cpuStepFan1[2]}
echo "Setting Fan 1 to Mode ${cpuStepFan1[2]} as cpu temperature above ${cpuStepTemp[1]}"
	if (( $fanNum == 2 ))     #assumes we do not have three fans!
	then
	hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=1,mode=${cpuStepFan2[2]}
	echo "Setting Fan 2 to Mode ${cpuStepFan2[2]} as cpu temperature above ${cpuStepTemp[1]}"
	fi
fi

if (( "$cpuTemp" > "${cpuStepTemp[2]}" )) && (( "$cpuTemp" <= "${cpuStepTemp[3]}" ))
then
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=0,mode=${cpuStepFan1[3]}
echo "Setting Fan 1 to Mode ${cpuStepFan1[3]} as cpu temperature above ${cpuStepTemp[2]}"
	if (( $fanNum == 2 ))     #assumes we do not have three fans!
	then
	hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=1,mode=${cpuStepFan2[3]}
	echo "Setting Fan 2 to Mode ${cpuStepFan2[3]} as cpu temperature above ${cpuStepTemp[2]}"
	fi
fi

if (( "$cpuTemp" > "${cpuStepTemp[3]}" )) && (( "$cpuTemp" <= "${cpuStepTemp[4]}" ))
then
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=0,mode=${cpuStepFan1[4]}
echo "Setting Fan 1 to Mode ${cpuStepFan1[4]} as cpu temperature above ${cpuStepTemp[3]}"
	if (( $fanNum == 2 ))     #assumes we do not have three fans!
	then
	hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=1,mode=${cpuStepFan2[4]}
	echo "Setting Fan 2 to Mode ${cpuStepFan2[4]} as cpu temperature above ${cpuStepTemp[3]}"
	fi
fi

if (( "$cpuTemp" > "${cpuStepTemp[4]}" )) && (( "$cpuTemp" <= "${cpuStepTemp[5]}" ))
then
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=0,mode=${cpuStepFan1[5]}
echo "Setting Fan 1 to Mode ${cpuStepFan1[5]} as cpu temperature above ${cpuStepTemp[4]}"
	if (( $fanNum == 2 ))     #assumes we do not have three fans!
	then
	hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=1,mode=${cpuStepFan2[5]}
	echo "Setting Fan 2 to Mode ${cpuStepFan2[5]} as cpu temperature above ${cpuStepTemp[4]}"
	fi
fi

if (( "$cpuTemp" > "${cpuStepTemp[5]}" )) && (( "$cpuTemp" <= "${cpuStepTemp[6]}" ))
then
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=0,mode=${cpuStepFan1[6]}
echo "Setting Fan 1 to Mode ${cpuStepFan1[6]} as cpu temperature above ${cpuStepTemp[5]}"
	if (( $fanNum == 2 ))     #assumes we do not have three fans!
	then
	hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=1,mode=${cpuStepFan2[6]}
	echo "Setting Fan 2 to Mode ${cpuStepFan2[6]} as cpu temperature above ${cpuStepTemp[5]}"
	fi
fi

# Fan Step Speed 7 set fan speed to highest level set in cpuStepTemp
if (( "$cpuTemp" > "${cpuStepTemp[6]}" ))
then
hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=0,mode=${cpuStepFan1[6]}
echo "Setting Fan 1 to Mode ${cpuStepFan1[6]} as cpu temperature above ${cpuStepTemp[6]}"
	if (( $fanNum == 2 ))     #assumes we do not have three fans!
	then
	hal_app --se_sys_set_fan_mode enc_sys_id=root,obj_index=1,mode=${cpuStepFan2[6]}
	echo "Setting Fan 2 to Mode ${cpuStepFan2[6]} as cpu temperature above ${cpuStepTemp[6]}"
	fi
fi

# Check CPU temperature every 15 seconds
echo "==================================================="
echo "Sleeping for 15 seconds"
echo "==================================================="
sleep 15

done

else 

echo "========================================================"
echo "Your model is not supported, please file an issue "
echo "at https://github.com/edddeduck/QNAP_Fan_Control/issues"
echo "include all the information above in the issue"
echo "========================================================"

fi
