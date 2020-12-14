# Docker Github Runners

Docker Runner nos permitirá ejecutar acciones self-hosted desde nuestro propia infraestructura.
En mi caso está orientado la la ejecución en un entorno ARM.


## Crear Imagen Docker para el Runner


Construimos la imagen Docker del agente que vamos a conectar a nuestra organización Github.

```
# Dockerfile
# base
FROM ubuntu:18.04

# set the github runner version
ARG RUNNER_VERSION="2.263.0"

# update the base packages and add a non-sudo user
RUN apt-get update -y && apt-get upgrade -y && useradd -m docker

# install python and the packages the your code depends on along with jq so we can parse JSON
# add additional packages as necessary
RUN apt-get install -y curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev

# cd into the user directory, download and unzip the github actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# copy over the start.sh script
COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]

```


``` bash
$ docker build -t jmmirand/gha-docker-self-hosted --build-arg RUNNER_VERSION=2.274.2 .
```


Fichero arranque.

```
#!/bin/bash

ORGANIZATION=$ORGANIZATION
ACCESS_TOKEN=$ACCESS_TOKEN
LABELS=$LABELS

REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/orgs/${ORGANIZATION}/actions/runners/registration-token | jq .token --raw-output)

cd /home/docker/actions-runner

./config.sh --url https://github.com/${ORGANIZATION} --token ${REG_TOKEN}  --labels ${LABELS}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!

```

Se crea la imagen asegurando los parámetros obligatorios.

  * **RUNNER_VERSION**: Versión latest del agente de Github Runner
[actions/runner/releases](https://github.com/actions/runner/releases).

  * **ARQ_RUNNER** : Arquitectura del runner ejemplo linux-x86

```
$ docker build \
    -t jmmirand/gha-docker-self-hosted \
    --build-arg RUNNER_VERSION=2.274.2 \
    --build-arg ARQ_RUNNER=linux-arm64 \
    .
```

## Arrancar Docker Runner y registrar el runner

Ejecutamos la imagen recién creada con los parámetros obligatorios:

 * **ACCESS_TOKEN** : PAT de un usuario con permisos de owner en la organización
y permisos de admin organization.
 * **ORGANIZATION** : Nombre de la organización
 * **LABELS** : Etiquetas que queremos que lleve el ejecutor.

```
$ docker run \
  --detach \
  --privileged \
  --env ORGANIZATION=jmmirand-kube-example \
  --env ACCESS_TOKEN=ea41fa221e7c8096cfbabb52cda5a9a8a3b6b036 \
  --env LABELS=docker-runner \
  --name runner \
  --network some-network \
  -e DOCKER_TLS_CERTDIR=/certs \
  -v some-docker-certs-client:/certs/client:ro \
  -e DOCKER_HOST=tcp://some-docker:2376 \
  jmmirand/gha-docker-self-hosted:latest
```

Comprobamos los logs para ver si se ha conectado correctamente.

```
$ docker logs -f runner

--------------------------------------------------------------------------------
|        ____ _ _   _   _       _          _        _   _                      |
|       / ___(_) |_| | | |_   _| |__      / \   ___| |_(_) ___  _ __  ___      |
|      | |  _| | __| |_| | | | | '_ \    / _ \ / __| __| |/ _ \| '_ \/ __|     |
|      | |_| | | |_|  _  | |_| | |_) |  / ___ \ (__| |_| | (_) | | | \__ \     |
|       \____|_|\__|_| |_|\__,_|_.__/  /_/   \_\___|\__|_|\___/|_| |_|___/     |
|                                                                              |
|                       Self-hosted runner registration                        |
|                                                                              |
--------------------------------------------------------------------------------

# Authentication


√ Connected to GitHub

# Runner Registration

Enter the name of runner: [press Enter for 080df422b9f8]

√ Runner successfully added
√ Runner connection is good

# Runner settings

Enter name of work folder: [press Enter for _work]
√ Settings Saved.


√ Connected to GitHub

2020-12-11 18:19:00Z: Listening for Jobs
```

## Probar Docker Runners

Este runner ya está para probarse.
``` yaml
# This is a basic workflow to help you get started with Actions

name: CI-docker-self-hosted

# Controls when the action will run.
on:
  # Triggers the workflow on push or pull request events but only for the main branch
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  my_job_docker_slef_hosted:
    runs-on: docker-runner
    steps:
      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      - uses: actions/checkout@v2
      # Runs a single command using the runners shell
      - name: Run a multi-line script
        run: |
          echo Add other actions to build,
          echo test, and deploy your project.
          ls -lrt
```


## Extender funcionalidad de los Runners

El siguiente paso es hacer crecer la imagen del runner para poder ejecutar
cualquier tipo de acción que estemos buscando realizar.

Además hay que dar capacidad de ejecución de Docker dentro del Runner, la razón,
es un tipo de acción básica de Github Actions.


### Intalar Docker Deamon y Docker Client

Para usar docker necesitamos tener un servidor (dockerd) y un cliente. Lo ideal
sería que todo a su vez se ejecutara dentro del contenedor del Runner. Esto
me permitiría tener nuestro runner aislado del Host.

Para esta funcionalidad usaremos dos contenedores conectados uno el demonio y
otro el cliente.

### Arrancer Docker in Docker (Server)

Arrancamos el demonio usando :
  * **DOCKER_TLS_CERTDIR=''** : La comunicación se raliza sin TLS
  * **docker:dind** : Imagen oficial de docker in docker.

``` bash
$ docker network create some-network

$ docker run --privileged --name some-docker -d  \
   --network some-network --network-alias docker \
   -e DOCKER_TLS_CERTDIR='' \
   docker:dind

```

### Arrancar runner con cliente docker instalado.

Debemos regenerar la imagen del contenedor añadiendo la instalación del cliente
docker en el fichero Dockerfile

```
# Dockerfile
.............................

# make the script executable
RUN chmod +x start.sh

RUN curl -sSL https://get.docker.com | sh
RUN usermod -aG docker docker

............................


```

Arrancamos el runner.

``` bash
$ docker run   --detach   --privileged \
    --env ORGANIZATION=jmmirand-kube-example   \
    --env ACCESS_TOKEN=ea41fa221e7c8096cfbabb52cda5a9a8a3b6b036  \
    --env LABELS=docker-runner   \
    --name runner   \
    --network some-network   \
    -e DOCKER_HOST=tcp://some-docker:2375 \
    jmmirand/gha-docker-self-hosted:latest
```

Comprobamos que docker está disponible.

```bash

$ docker exec -ti runner /bin/bash

docker@15fae54fe9bc:/$ docker ps

CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

docker@15fae54fe9bc:/$ docker run --rm hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
256ab8fe8778: Pull complete
Digest: sha256:1a523af650137b8accdaed439c17d684df61ee4d74feac151b5b337bd29e7eec
Status: Downloaded newer image for hello-world:latest

Hello from Docker!

```


### Referencias

  * [How to Use the "docker" Docker Image to Run Your Own
    Docker daemon](https://www.caktusgroup.com/blog/2020/02/25/docker-image/)
  * [Docker Official Images](https://hub.docker.com/_/docker)
