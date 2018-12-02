# webvnc-installer

> An automatic WebVNC system install script

> Only for Debian-like server systems (Ubuntu Server, etc.)
> **without a desktop environment preinstalled!**

### Download
```bash
wget --content-disposition https://webvnc-installer.now.sh

chmod +x ./webvnc-installer.sh

./webvnc-installer.sh
```

### Features
- Installs the Lubuntu desktop environment
- Compiles x11vnc server automatically
- Creates & registers HTTPS certificate automatically
- Sets up noVNC server
- Configures auto start (noVNC & x11vnc)
- **Supports native graphical user login**

### To do
- [ ] Reverse proxy
- [ ] Fix screen sleep lock out