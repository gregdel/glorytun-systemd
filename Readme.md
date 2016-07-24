# glorytun systemd service

### Installation

Download the latest glorytun-mud version from [here](https://github.com/angt/glorytun/releases) and save it in /usr/sbin/glorytun

### Configuration

Write the env in /etc/glorytun/env

```
GLORYTUN_HOST=server_ip
GLORYTUN_PORT=server_port
```

Write the raw key in /etc/glorytun/key

### Enable the service

```
ln -s the_service_path /etc/systemd/system/glorytun.service
systemctl daemon-reload
```

### Start the service

```
systemctl start glorytun
```

### Stop the service

```
systemctl stop glorytun
```

### Hook glorytun with NetwokManager

Copy the glorytun-hook.sh, make sure it is owned by root !

This script will be executed by NetworkManager everytime an interface goes up or down. You can edit and tweak it.


```
cp glorytun-hook.sh /etc/NetworkManager/dispatcher.d/glorytun-hook.sh
```
