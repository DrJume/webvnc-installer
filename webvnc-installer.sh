#!/bin/bash

# WebVNC Installer
if [ "$#" -gt 2 ]; then
	echo "Too many arguments!"
	echo
fi

if [ "$#" -ne 2 ]; then
	echo "[WebVNC Installer] by DrJume"
	echo "=========================="
	echo "Arguments needed: <cert-domain> <cert-email>"
	echo
	echo "		cert-domain: Domain (or subdomain) used for HTTPS certificate."
	echo "		cert-email: E-Mail address associated with your domain HTTPS certificate."
	echo 
	echo "~ root privileges needed!"
	exit 1
fi

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root!"
  exit 1
fi

echo "[WebVNC Installer] Installing lubuntu-desktop (and other packages)"
apt update && apt-get upgrade -y
apt install -y lubuntu-desktop wget autoconf gcc pkg-config libssl-dev libx11-dev libxtst-dev libvncserver-dev screen
echo "[WebVNC Installer] Building and installing x11vnc"
cd /root/
wget https://github.com/LibVNC/x11vnc/archive/0.9.15.tar.gz
tar xfvz 0.9.15.tar.gz
cd x11vnc-0.9.15
./autogen.sh
make
make install
echo "[WebVNC Installer] Installing certbot"
add-apt-repository ppa:certbot/certbot -y
apt update
apt install certbot -y
echo "[WebVNC Installer] Registering HTTPS certificate"
certbot certonly -n --standalone -d $1 --email $2 --agree-tos
echo "[WebVNC Installer] Preparing certificate for noVNC"
cd /etc/letsencrypt/live/$1/
cat cert.pem >> certkey.pem
cat privkey.pem >> certkey.pem
echo "[WebVNC Installer] Installing noVNC"
cd /root/
wget https://github.com/novnc/noVNC/archive/v1.0.0.tar.gz
tar xfvz v1.0.0.tar.gz
echo "[WebVNC Installer] Writing start scripts"
echo "screen -dmS novnc /root/noVNC-1.0.0/utils/launch.sh --vnc localhost:5900 --listen 443 --cert /etc/letsencrypt/live/"$1"/certkey.pem" > novnc.sh
echo "screen -dmS x11vnc sudo x11vnc -norc -allow 127.0.0.1 -defer 10 -display :0 -forever -listen localhost -localhost -logfile /root/.x11vnc.log -wait 10 -xkb -auth /var/lib/lightdm/.Xauthority" > x11vnc.sh
chmod +x novnc.sh x11vnc.sh
echo "[WebVNC Installer] Setting lightdm hook to start x11vnc when login screen starts"
cat > /etc/lightdm/lightdm.conf.d/50-x11vnc.conf <<EOL
[Seat:*]
greeter-setup-script=/root/x11vnc.sh
EOL
echo "[WebVNC Installer] Adding cronjob to start noVNC on system start"
crontab -l | { cat; echo "@reboot /root/novnc.sh"; } | crontab -

echo "##################################################################################"
echo "Done."
echo "> To turn up the display resolution, edit /etc/default/grub and run sudo update-grub"
echo "Please reboot the system!"