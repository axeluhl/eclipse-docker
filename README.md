Launch with

```
  docker-compose up --build -d
```

Get a shell in the container:

```
   docker exec -it eclipse-ide /bin/bash
```

Add ``--user root`` in case you need to become root in that container.

Create a ``.env`` file in this git workspace folder, like this:

```
UID=1000
GID=1000
WORKSPACE=/usr/local/src/my-local-workspace
```

The ``eclipse-install`` docker volume will store your installation including plug-ins etc.
persistently. Each time you restart a stopped container or launch or build this from scratch
again, your ``eclipse-install`` volume will hold the entire Eclipse installation.
