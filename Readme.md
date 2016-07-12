# glorytun systemd service

### Installation

Download the latest glorytun-mud version from [here](https://github.com/angt/glorytun/releases) and save it in /usr/sbin/glorytun

### Configuration

Write the env in /etc/glorytun/env

```
GLORYTUN_INPUT_DEV=interface_name
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
