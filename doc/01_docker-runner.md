<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Github Runners con Docker](#github-runners-con-docker)
  - [Crear DockerFile y construción de la imágen.](#crear-dockerfile-y-construci%C3%B3n-de-la-im%C3%A1gen)
    - [Basar la imagen docker en ubuntu](#basar-la-imagen-docker-en-ubuntu)
    - [Instalación Utilidades](#instalaci%C3%B3n-utilidades)
    - [Instalación Docker Deamon](#instalaci%C3%B3n-docker-deamon)
    - [Instalación del agente github](#instalaci%C3%B3n-del-agente-github)
    - [Copiar ENTRYPOINT](#copiar-entrypoint)
  - [Entrypoint start.sh](#entrypoint-startsh)
  - [Build imagen Docker](#build-imagen-docker)
  - [Probar Docker Runners](#probar-docker-runners)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Github Runners con Docker

En un contenedor Docker podemos instalar y registrar el runner. Este cuando se arranque
se registrará en github disponibilizado para los worlflows.


## Crear DockerFile y construción de la imágen.

Para la construcción de la imagen Docker tendremos en cuenta

### Basar la imagen docker en ubuntu
Basamos nuestra imagen Docker en ubuntu porque en Raspberry el SO esta también está
basado en linux y en mi caso está basado en ubuntu. También tendremos que tener
en cuenta que la construcción de la imagen debe ser en Arquitectura ARM.

``` bash
# Dockerfile
# base
FROM ubuntu:20.04
```

### Instalación Utilidades

Hay utilidades que se asume que tienen que debe estar instaladas en el Runner como por ejemplo git y python.
También por optimización se puede instalar utilidades que se van a usar muy frecuentemente y así mejorar
los tiempos de respuesta de las acciones.

``` bash
# install python and the packages the your code depends on along with jq so we can parse JSON
# add additional packages as necessary
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev
```

### Instalación Docker Deamon

La instalación de docker es recomendable si queremos queremos realizar trabajos
con docker (construcción de imágenes, push y ejecución de containers).

``` bash
# install some additional dependencies
# Install docker client.
RUN useradd -m docker
RUN curl -sSL https://get.docker.com | sh
RUN usermod -aG docker docker
RUN chown -R docker ~docker &&
```


### Instalación del agente github

Se calcula la última versión del agente y se instala.

``` bash
# cd into the user directory, download and unzip the github actions runner
RUN export RUNNER_VERSION=$(curl  --silent "https://api.github.com/repos/actions/runner/releases/latest" | grep "tag_name" | sed -E 's/.*"v([^"]+)".*/\1/') \
    && cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-${ARQ_RUNNER}-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-${ARQ_RUNNER}-${RUNNER_VERSION}.tar.gz

```

### Copiar ENTRYPOINT

Preparamos el entrypoint encapsulado en start.sh y añadimos el usuario por defecto
a Docker.

``` bash
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

## Entrypoint start.sh

El fichero de arranque tiene como propósito registrar el agente en la organización GitHub a
la que dará servicio el runner.

 * Recibe como parámetros.
   * Nombre de la organización
   * Access Token con permisos en la organización que queremos registrar.
   * Etiquetas con las que se registre en la organización.
   * Nombre del agente con el que arranca.

 * Con el access-token consigue un token de registro, que tiene una validez temporal.

```
REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/orgs/${ORGANIZATION}/actions/runners/registration-token | jq .token --raw-output)
```

 * Arrancar el agente.

```
./config.sh --url https://github.com/${ORGANIZATION} --token ${REG_TOKEN}  --labels ${LABELS} --name ${NAME}

```

 * En caso de fallo o parada del agente, des-registramos el agente de la organización

```
cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM
```

## Build imagen Docker

Para la construcción usamos como argumento la versión que quiero instalar.

``` bash
$ docker build -t jmmirand/gha-docker-self-hosted:latest  .
$ docker push
```


## Arrancar Github Runner

Ejecutamos la imagen recién creada con los parámetros obligatorios:

 * **ACCESS_TOKEN** : PAT de un usuario con permisos de owner en la organización
y permisos de admin organization.
 * **ORGANIZATION** : Nombre de la organización
 * **LABELS** : Etiquetas que queremos que lleve el ejecutor.

Esta forma de arrancar comunicamos el docker deamon que ejecuta dentro del contenedor
con el deamon del HOST

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


Una vez arrancado el runner, ya puede ser usado desde cualquier repositorio que
esté en la organización.

Creamos un repo vacío y añadimos el workflows

``` yaml
# This is a basic workflow to help you get started with Actions

name: CI-docker-self-hosted

# Controls when the action will run.
on: push

jobs:
  my_job_docker_self_hosted:
    runs-on: docker-runner
    steps:
      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      - uses: actions/checkout@v2
      # Runs a single command using the runners shell
      - name: Run a multi-line script
        run: |
          docker version
          echo Add other actions to build,
          echo test, and deploy your project.
          ls -lrt
```


### Referencias

  * [How to Use the "docker" Docker Image to Run Your Own
    Docker daemon](https://www.caktusgroup.com/blog/2020/02/25/docker-image/)
  * [Docker Official Images](https://hub.docker.com/_/docker)
