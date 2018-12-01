#!/bin/bash

# WebVNC installer
if [ "$#" -ne 2 ]; then
	echo "Arguments needed: <cert-domain> <cert-email>"
	exit 1
fi

# Install lubuntu-desktop and x11vnc (build it)
apt update && apt-get upgrade -y
apt install -y lubuntu-desktop wget autoconf gcc pkg-config libssl-dev libx11-dev libxtst-dev libvncserver-dev screen
cd /root/
wget https://github.com/LibVNC/x11vnc/archive/0.9.15.tar.gz
tar xfvz 0.9.15.tar.gz
cd x11vnc-0.9.15
./autogen.sh
make
make install
# Install certbot
add-apt-repository ppa:certbot/certbot -y
apt update
apt install certbot -y
certbot certonly -n --standalone -d $1 --email $2 --agree-tos
cd /etc/letsencrypt/live/$1/
cat cert.pem >> certkey.pem
cat privkey.pem >> certkey.pem
# Install noVNC
cd /root/
wget https://github.com/novnc/noVNC/archive/v1.0.0.tar.gz
tar xfvz v1.0.0.tar.gz
# Writing scripts
echo "screen -dmS novnc /root/noVNC-1.0.0/utils/launch.sh --vnc localhost:5900 --listen 443 --cert /etc/letsencrypt/live/"$1"/certkey.pem" > novnc.sh
echo "screen -dmS x11vnc sudo x11vnc -norc -allow 127.0.0.1 -defer 10 -display :0 -forever -listen localhost -localhost -logfile /root/.x11vnc.log -wait 10 -xkb -auth /var/lib/lightdm/.Xauthority" > x11vnc.sh
chmod +x novnc.sh x11vnc.sh
# Setting lightdm hook to start x11vnc when login screen starts
cat > /etc/lightdm/lightdm.conf.d/50-x11vnc.conf <<EOL
[Seat:*]
greeter-setup-script=/root/x11vnc.sh
EOL
# Setting Cronjob to start novnc on system start
crontab -l | { cat; echo "@reboot /root/novnc.sh"; } | crontab -

echo "#################################"
echo "Done!"
echo "To turn up the display resolution, edit /etc/default/grub and run sudo update-grub"
echo "Now please reboot the system"