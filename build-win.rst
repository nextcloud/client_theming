# Build docker

We use the original toolchain from ownCloud.
``docker build -t nextcloud-client-win32:<version> client/admin/win/docker/Dockerfile``

# Run docker
``docker run -v "$PWD:/home/user/" nextcloud-client-win32:2.2.2 /home/user/build-win.sh $(id -u)``

This will build your new win32 package in: `build-win32`
