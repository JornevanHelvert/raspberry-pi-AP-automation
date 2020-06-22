# Update the repos
echo ">>>>>>>>>>>>>>>>>>>> Updating all apt repos... <<<<<<<<<<<<<<<<<<<<"
apt-get update -y

# Upgrade the repos
echo ">>>>>>>>>>>>>>>>>>>> Upgrading all apt repos... <<<<<<<<<<<<<<<<<<<<"
apt-get upgrade -y

# Updating the OS
echo ">>>>>>>>>>>>>>>>>>>> Updating Raspberry Pi OS... <<<<<<<<<<<<<<<<<<<<"
rpi-update -y

# Install hostapd
echo ">>>>>>>>>>>>>>>>>>>> Installing hostapd... <<<<<<<<<<<<<<<<<<<<"
apt-get install hostapd -y

# Install dnsmasq
echo ">>>>>>>>>>>>>>>>>>>> Installing dnsmasq... <<<<<<<<<<<<<<<<<<<<"
apt-get install dnsmasq -y

# Stop hostapd
echo ">>>>>>>>>>>>>>>>>>>> Stopping hostapd... <<<<<<<<<<<<<<<<<<<<"
systemctl stop hostapd
echo ">>>>>>>>>>>>>>>>>>>> Hostapd stopped. <<<<<<<<<<<<<<<<<<<<"

# Stop dnsmasq
echo ">>>>>>>>>>>>>>>>>>>> Stopping dnsmasq... <<<<<<<<<<<<<<<<<<<<"
systemctl stop dnsmasq
echo ">>>>>>>>>>>>>>>>>>>> Dnsmasq stopped. <<<<<<<<<<<<<<<<<<<<"

# Write config to /etc/dhcpcd.conf and using 192.168.0.40 as the AP's IP address
echo ">>>>>>>>>>>>>>>>>>>> Configuring dhcpcd.conf... <<<<<<<<<<<<<<<<<<<<"
echo "interface wlan0
static ip_address=192.168.0.40/24
denyinterfaces eth0
denyinterfaces wlan0" > /etc/dhcpcd.conf
echo ">>>>>>>>>>>>>>>>>>>> Configuration writen to file successfuly! <<<<<<<<<<<<<<<<<<<<"

# Change name of current dnsmasq config file
echo ">>>>>>>>>>>>>>>>>>>> Renaming dnsmasq.conf to dnsmasq.conf.original in /etc... <<<<<<<<<<<<<<<<<<<<"
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.original
echo Renaming completed!

# Write new dnsmasq config to config file using IP range 192.168.0.41 until 192.168.0.60
echo ">>>>>>>>>>>>>>>>>>>> Writing new config to dnsmasq.conf file... <<<<<<<<<<<<<<<<<<<<"
echo "interface=wlan0
  dhcp-range=192.168.0.41,192.168.0.60,255.255.255.0,24h" > /etc/dnsmasq.conf
echo ">>>>>>>>>>>>>>>>>>>> Configuration writen to file! <<<<<<<<<<<<<<<<<<<<"

# Make the user enter a ssid for the AP
echo Please enter an ssid for the Access Point:
read -r ssid

# Make the user enter a WPA2-Personal password for the AP
echo Please enter a password for the Access Point:
read -r password

# Write hostapd config to /etc/hostapd/hostapd.conf
echo ">>>>>>>>>>>>>>>>>>>> Writing hostapd config to required file... <<<<<<<<<<<<<<<<<<<<"
echo "interface=wlan0
bridge=br0
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=1
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
ssid=$ssid
wpa_passphrase=$password" > /etc/hostapd/hostapd.conf
echo ">>>>>>>>>>>>>>>>>>>> Configuration writen to file! <<<<<<<<<<<<<<<<<<<<"

# Replace DAEMON_CONF=”” with the path to the hostapd config and uncomment the line
echo ">>>>>>>>>>>>>>>>>>>> Setting path to deamon configuration in default hostapd file... <<<<<<<<<<<<<<<<<<<<"
sed -i 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|g' /etc/default/hostapd
echo ">>>>>>>>>>>>>>>>>>>> Deamon configuration updated! <<<<<<<<<<<<<<<<<<<<"

# Setup traffic forwarding by uncommenting line in /etc/sysctl.conf
echo ">>>>>>>>>>>>>>>>>>>> Setting up traffic forwarding... <<<<<<<<<<<<<<<<<<<<"
sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|g' /etc/sysctl.conf
echo ">>>>>>>>>>>>>>>>>>>> Traffic forwarding enabled! <<<<<<<<<<<<<<<<<<<<"

# Setup IP tables
echo ">>>>>>>>>>>>>>>>>>>> adding IP masquerading for outbound traffic on eth0 using iptables... <<<<<<<<<<<<<<<<<<<<"
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
echo ">>>>>>>>>>>>>>>>>>>> added IP masquerading! <<<<<<<<<<<<<<<<<<<<"

# Save IP tables rule
sh -c "iptables-save > /etc/iptables.ipv4.nat"

# Load the rule on boot by adding this line above exit 0 in /etc/rc.local
echo ">>>>>>>>>>>>>>>>>>>> Making sure rule loads on boot... <<<<<<<<<<<<<<<<<<<<"
sed -i 's|^exit 0*|iptables-restore < /etc/iptables.ipv4.nat|g' /etc/rc.local
echo exit 0 >> /etc/rc.local
echo ">>>>>>>>>>>>>>>>>>>> Rule loads on boot! <<<<<<<<<<<<<<<<<<<<"

# Install bridge utils
echo ">>>>>>>>>>>>>>>>>>>> Installing bridge utils... <<<<<<<<<<<<<<<<<<<<"
apt-get install bridge-utils

# Adding a bridge called br0
echo ">>>>>>>>>>>>>>>>>>>> adding a bridge called br0 <<<<<<<<<<<<<<<<<<<<"
brctl addbr br0
echo ">>>>>>>>>>>>>>>>>>>> br0 added! <<<<<<<<<<<<<<<<<<<<"

# Connecting the bridge to eth0
echo ">>>>>>>>>>>>>>>>>>>> Connecting br0 to eth0 <<<<<<<<<<<<<<<<<<<<"
brctl addif br0 eth0
echo ">>>>>>>>>>>>>>>>>>>>>> Br0 connected to eth0! <<<<<<<<<<<<<<<<<<<<"

# Adding config to the interfaces file
echo ">>>>>>>>>>>>>>>>>>>>>> adding config to the interfaces file... <<<<<<<<<<<<<<<<<<<<"
echo "auto br0
iface br0 inet manual
bridge_ports eth0 wlan0" >> /etc/network/interfaces
echo ">>>>>>>>>>>>>>>>>>>>>> config added! <<<<<<<<<<<<<<<<<<<<"

# Reboot the PI for configurations to load
echo ">>>>>>>>>>>>>>>>>>>>>> rebooting... <<<<<<<<<<<<<<<<<<<<"
reboot
