## Arrancar Runner con Docker Compose

Con Docker Compose obtenemos escalabilidad vertical. Nos permite tener varios
ejecutores en la misma Hosted.

El fichero de manifiesto.

```
#docker-compose.yml
version: '3'

services:
  runner:
    build: ../docker/
    environment:
      - ORGANIZATION=jmmirand-kube-example
      - ACCESS_TOKEN=xxxxxxxxxxxxxxxxxxxxx  
      - LABES=docker-compose-runner
```

* Ejecutamos

``` bash
# Construcción de la imagen
$ docker-compose build --build-arg RUNNER_VERSION=2.274.2   --build-arg ARQ_RUNNER=linux-arm64

# Arranque un nodo
$ docker-compose up -d .

# Arranque servicio runners con dos nodos
$ docker-compose up --build --scale runner=2
```
