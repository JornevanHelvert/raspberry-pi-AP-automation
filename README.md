 # RPI Access Point automation script

### Purpose:
For those of you who have tried to make an access point using a Raspberry Pi 
may have stumbled upon the same issues as I have. My access point would stop 
working from time to time and rather then keep repeating the same set-up I automated it.
I will not broadcast the access points ssid 
since I want to make a private hidden network. If you have an other use case feel free
to edit the script.

### Prerequisites:

* First of all make sure that your Pi has WiFi support. If you have a Raspberry Pi 3 or 
newer this should not be a problem but you can check your device specs when you scroll down 
to Raspberry Pi Boards and select your device [here](https://www.raspberrypi.org/products/)

* This script is based on Raspberry Pi OS (which used to be called Raspbian) so
make sure you have you have this or another debian based distro installed. You can
download Raspberry Pi OS [here](https://www.raspberrypi.org/downloads/raspberry-pi-os/)

* Make sure your WLAN country is set you can do this by typing `sudo raspi-config` 
and then choosing `4 Localisation Options` > `l4 Change WLAN Country` select your country from the list here.

* If you want to clone the repo directly on your Raspberry Pi you need to install git.
You can use this command to do so:


    sudo apt-get install git

* Next clone the repo into a chosen directory by using this command:


    git clone https://github.com/JornevanHelvert/raspberry-pi-AP-automation.git

* If you want to broadcast the ssid you can change `ignore_broadcast_ssid` to `0` 
instead of `1` in the `/etc/hostapd/hostapd.conf` file. You can edit using any text 
editor for example vim or nano.

### Execute the script:

* First of all you need to make sure the script is executable for the root user.
You can do this by using the following command in the raspberry-pi-AP-automation directory:


    sudo chmod +x ap_setup.sh

* Now you can run the script using the following command:


    sudo ./ap_setup.sh

The script will start with updating the dependencies of your Pi and making sure the 
latest version of Raspberry Pi OS is installed and that's why you need to run it as 
root.

### Contact

Important note is that I'm not really an expert in IoT I work as a Frontend 
Developer and IoT is more of a hobby for me so feel free to contact me if you 
have any remark. It would be nice to learn from others and hopefully some of you will
experience some benefits of this script as well. You can contact me on my e-mail address: `jorne.van.helvert@gmail.com`





