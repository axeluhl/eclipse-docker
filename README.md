Launch with

```
  docker-compose up --build -d
```

Get a shell in the container:

```
   docker exec -it eclipse-ide /bin/bash
```

Create a ``.env`` file in this git workspace folder, like this:

```
UID=1000
GID=1000
WORKSPACE=/usr/local/src/my-local-workspace
```
