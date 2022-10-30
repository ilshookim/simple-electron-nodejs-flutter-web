# Serial

Basic CRUD for serial port interacting with the JSON API's config resources.

## Serial

## List

### Request

```shell
curl \
  -X GET \
  http://localhost:8090/serial
```

### Response

```json
{
  "ok": true,
  "message": "Serial port list",
  "ports": [
    {
      "path": "/dev/tty.Bluetooth-Incoming-Port"
    }
  ]
}
```

## Open

### Request

```shell
# open broadcast
curl \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"path":"/dev/tty.Bluetooth-Incoming-Port", "baudRate": 115200}' \
  http://localhost:8090/serial/open

# open with websocket uid
curl \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"path":"/dev/tty.Bluetooth-Incoming-Port", "baudRate": 115200, "websocket":"xBkRkQmGzJ"}' \
  http://localhost:8090/serial/open
```

### Response

```json
{
  "ok": true,
  "message": "Serial port open",
  "serial": {
    "open": {
      "path":"/dev/tty.Bluetooth-Incoming-Port",
      "baudRate":115200,
      "websocket":"xBkRkQmGzJ"
    },
    "state":"open"
  }
}
```

## Close

### Request

```shell
# close broadcast
curl \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"path":"/dev/tty.Bluetooth-Incoming-Port"}' \
  http://localhost:8090/serial/close

# close with websocket uid
curl \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"path":"/dev/tty.Bluetooth-Incoming-Port", "websocket":"xBkRkQmGzJ"}' \
  http://localhost:8090/serial/close
```

### Response

```json
{
  "ok": true,
  "message": "Serial port close",
  "serial": {
    "open": {
      "path":"/dev/tty.Bluetooth-Incoming-Port",
      "websocket":"xBkRkQmGzJ"
    },
    "state":"close"
  }
}
```
