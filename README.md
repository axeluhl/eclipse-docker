Use this project to create a Docker image that can serve an up-to-date Eclipse version, independent
of your host's operating system currentness.

Launch with

```
  docker-compose up --build -d
```

and do your usual Eclipse set-up with plug-in installation, or importing software packages
from a file, or whatever you do to make yourself a home in your Eclipse environment.

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

If you want to upgrade, change the volume name in docker-compose.yml, upgrade the Eclipse
download URL in Dockerfile, make a new image using ``docker build .``, tag it accordingly
and update the docker-compose.yml to use your new image. It's important to change to a new
volume name because otherwise you'll keep getting served the old version located in the
old volume. Once you're happy with the new environment you may as well ``docker volume rm {old-volume}``
to clean up.

When first running this (also after an upgrade), go through the usual onboarding procedure
for your Eclipse environment, such as importing software packages from file or installing
other required plug-ins.
