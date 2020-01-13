# webvnc-installer

> Quickly builds a VNC cloud instance. Especially good when programming in a restricted network (e.g. schools)

> Tested on Ubuntu Server 18.04

### Download
```shell
wget https://raw.githubusercontent.com/DrJume/webvnc-installer/master/webvnc-installer.sh

chmod +x ./webvnc-installer.sh

./webvnc-installer.sh
```

### Features
- Installs the Lubuntu desktop environment
- **Supports native graphical user login**
- Compiles x11vnc server automatically
- Creates & registers HTTPS certificate automatically
- Sets up noVNC server
- Configures auto start (noVNC & x11vnc)

### To do
- [ ] Reverse proxy
- [ ] Fix screen sleep lock out
