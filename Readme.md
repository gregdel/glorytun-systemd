# glorytun systemd service

### Installation

```
sudo ./install.sh
```

### Configuration

Write the env in /etc/glorytun/env

```
GLORYTUN_DEV=mud0
GLORYTUN_HOST=server_ip
GLORYTUN_PORT=server_port
GLORYTUN_MTU=1400
```

Write the raw key in /etc/glorytun/key

### Enable the service

```
systemctl enable glorytun
```

### Start the service

```
systemctl start glorytun
```

### Stop the service

```
systemctl stop glorytun
```
