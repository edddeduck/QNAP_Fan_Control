# QNAP_Fan_Control
20th August 2016

Basic Fan Control Script for QNAP Devices. This replaces the SMART fan control with a script that monitors your CPU temperature and alters the fan speed based on your CPU temperature.

This is useful for people who have upgraded their CPU as the QNAP smart fan control will stop working & ramp up to full speed and not slow down.

HEALTH WARNING - This script is *not* wonderfully written, it was written as a quick and dirty solution to a problem I had in a single evening, once it started working I was happy. 

It's completely designed with my setup in mind but reading all of the other people who have similar issues but have no solution made me think I could share what I managed to work out so far.

1. Copy the script onto to your QNAP
2. Macke sure you have disabled fan speed on your QNAP and set the fans to manual (high) instead.
3. SSH into your machine and start the script
4. Make sure you run the script in such a way it KEEPS RUNNING when you close your SSH session.

The script uses a command that allows you to control the speed of the large QNAP fans individually. It then checks the CPU temperature and alters the fan speed accordingly. There are 8 levels of fan speed depending on the temperatures.

I've have some rough notes in the script.