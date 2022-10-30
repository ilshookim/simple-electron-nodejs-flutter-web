# Config

Basic CRUD for interacting with the JSON API's config resources.

## Create

### Request

```shell
curl \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"key":"my-config", "value":"This is my description of this config."}' \
  http://localhost:8090/config
```

### Response

```json
{
  "ok": true,
  "message": "Config created",
  "config": {
    "id": 1,
    "key": "my-config",
    "value": "This is my description of this config.",
    "created_at": "2018-04-03 14:43:02.183277-04",
    "updated_at": "2018-04-03 14:43:02.183277-04"
  }
}
```

## List

### Request

```shell
curl \
  -X GET \
  http://localhost:8090/config
```

### Response

```json
{
  "ok": true,
  "message": "Configs list",
  "configs": [
    {
      "id": 1,
      "key": "my-config",
      "value": "This is my description of this config.",
      "created_at": "2018-04-03 14:43:02.183277-04",
      "updated_at": "2018-04-03 14:43:02.183277-04"
    },
    {
      "id": 2,
      "key": "my-other-config",
      "value": "This is my other config description.",
      "created_at": "2018-04-03 14:43:02.183277-04",
      "updated_at": "2018-04-03 14:43:02.183277-04"
    }
  ]
}
```

## Get

### Request

```shell
curl \
  -X GET \
  http://localhost:8090/config/key/my-config

curl \
  -X GET \
  http://localhost:8090/config/key/Another%20Config
```

### Response

```json
{
  "ok": true,
  "message": "Config found",
  "config": {
    "id": 1,
    "key": "my-config",
    "value": "This is my description of this config.",
    "created_at": "2018-04-03 14:43:02.183277-04",
    "updated_at": "2018-04-03 14:43:02.183277-04"
  }
}
```

## Update

### Request

```shell
curl \
  -X PUT \
  -H "Content-Type: application/json" \
  -d '{"value":"This is just a sample config to updated at this time"}' \
  http://localhost:8090/config/key/my-config
```

### Response

```json
{
  "ok": true,
  "message": "Config updated",
  "config": {
    "id": 1,
    "key": "my-config",
    "value": "This is just a sample config to updated at this time",
    "created_at": "2018-04-03 14:43:02.183277-04",
    "updated_at": "2018-04-03 14:43:02.183277-04"
  }
}
```

## Delete

### Request

```shell
curl \
  -X DELETE \
  http://localhost:8090/config/key/my-config
```

### Response

```json
{
  "ok": true,
  "message": "Config deleted",
  "deleteCount": 1
}
```
