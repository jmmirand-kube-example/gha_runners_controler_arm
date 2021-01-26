<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Github runner con un docker in docker](#github-runner-con-un-docker-in-docker)
  - [Instalar Docker Deamon y Docker Client](#instalar-docker-deamon-y-docker-client)
  - [Arrancar Runner & Docker in Docker (Server)](#arrancar-runner--docker-in-docker-server)
  - [Comprobar y chequear el Runner](#comprobar-y-chequear-el-runner)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


# Github runner con un docker in docker

Una vez instalado el runner que se maneja el demonio docker del HOST, mejoraremos
la instalación haciendo que use el demonio docker que está en otro contenedor.

Esto evita que el runner tenga acceso al HOST y salvaguardemos a este de algún
uso indebido.

Para esta funcionalidad usaremos dos contenedores conectados uno el dind y
otro el propio runner, ambos en la misma red

## Instalar Docker Deamon y Docker Client

Para usar docker necesitamos tener un servidor (dockerd) y un cliente. Lo ideal
sería que todo a su vez se ejecutara dentro del contenedor del Runner. Esto
me permitiría tener nuestro runner aislado del Host.


## Arrancar Runner & Docker in Docker (Server)

Para arrancamos el demonio en dind lo hacemos desactivando los certificados:
  * **DOCKER_TLS_CERTDIR=''** : La comunicación se realiza sin TLS
  * **docker:dind** : Imagen oficial de docker in docker.

Después se arranca el runner en la misa red que el demonio docker.

``` bash
$ docker network create some-network

$ docker run --privileged --name some-docker -d  \
   --network some-network --network-alias docker \
   -e DOCKER_TLS_CERTDIR='' \
   docker:dind

$ docker run   --detach   --privileged \
   --env ORGANIZATION=jmmirand-kube-example   \
   --env ACCESS_TOKEN=ea41fa221e7c8096cfbabb52cda5a9a8a3b6b036  \
   --env LABELS=docker-runner   \
   --name runner   \
   --network some-network   \
   -e DOCKER_HOST=tcp://some-docker:2375 \
   jmmirand/gha-docker-self-hosted:latest


```

## Comprobar y chequear el Runner

 * Comprobamos que el nuevo demonio docker está disponible.

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

 * Comprobamos el runner

```bash
$ docker logs runner

....
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
```
