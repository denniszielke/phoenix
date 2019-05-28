# Hint for local docker development

## Connecting to local docker daemon in a VM from Windows

Set Docker Host (https://docs.docker.com/machine/reference/env/) Check in the Docker Daemon in "General" the setting "Expose daemon on tcp://localhost:2375 without TLS"

```bash
export DOCKER_HOST=tcp://127.0.0.1:2375
```

## Installing docker on ubuntu

Via package manager

```bash
sudo apt install docker.io
```

Do not forget to make sure that the current user is part of the docker group

```bash
sudo usermod -aG docker $USER
```

Logout and log in again to make sure group membership get loaded

## Run nginx hello world

```bash
docker run --name docker-nginx -p 8080:80 nginx
```
