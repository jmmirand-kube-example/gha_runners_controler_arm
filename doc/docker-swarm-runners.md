## Docker Swarm runner ( Escalabilidad Vertical )

### Instalar el cluster

Inicializamos el cluster y le añadiemos un worker al cluster swarm

```bash

# Inicializar docker swarm en uno de los nodos.
node01 $ docker swarm init
Swarm initialized: current node (ueceg6yy3truou5t7xgk8sfk1) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-2k2q96qdwh33tolzw7tt0kdc64fn6vegu9oqv0h06vl4s0ts4q-3841r9pfn2rvg7zty0ftqhviz 192.168.1.13:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

# Unir un worker al nodo 1
node2 $ docker swarm join --token SWMTKN-1-2k2q96qdwh33tolzw7tt0kdc64fn6vegu9oqv0h06vl4s0ts4q-3841r9pfn2rvg7zty0ftqhviz 192.168.1.13:2377

```

Comprobamos que está bien configurado.

``` bash
$ docker node ls
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
m3tlq63k62lddk3q55xp7h8ah     worker02            Ready               Active                                  19.03.14
ueceg6yy3truou5t7xgk8sfk1 *   worker03            Ready               Active              Leader              19.03.14

```


### Subir imagen  docker runner a un repositorio docker

Subimos la imagen recién construida a docker-hub.

``` bash
$ docker login
....
Login Succeeded

  $ docker push jmmirand/gha-docker-self-hosted:latest
...
  $ docker stack ps -f "desired-state=running" actions
  ID                  NAME                IMAGE                                    NODE                DESIRED STATE       CURRENT STATE                  ERROR               PORTS
  fbqu0qn1z13k        actions_runner.1    jmmirand/gha-docker-self-hosted:latest   worker02            Running             Preparing about a minute ago
```

### Deploy servicio

```
$ docker stack deploy --compose-file=docker-swarm-runner-with-dockerd.yml actions
Ignoring unsupported options: privileged

Creating network actions_default
Creating service actions_dockerd-dd
Creating service actions_runner-dd

```
   * Logs de los servicios

```



### Escalar Runners

``` bash
$ docker service scale actions_runner=3
actions_runner scaled to 3
overall progress: 3 out of 3 tasks
1/3: running   [==================================================>]
2/3: running   [==================================================>]
3/3: running   [==================================================>]
verify: Service converged

$ docker stack ps -f "desired-state=running" actions
ID                  NAME                IMAGE                                    NODE                DESIRED STATE       CURRENT STATE            ERROR               PORTS
fbqu0qn1z13k        actions_runner.1    jmmirand/gha-docker-self-hosted:latest   worker02            Running             Running 10 minutes ago
za3xpil735cx        actions_runner.2    jmmirand/gha-docker-self-hosted:latest   worker02            Running             Running 9 seconds ago
ykll4szslu6g        actions_runner.3    jmmirand/gha-docker-self-hosted:latest   worker02            Running             Running 9 seconds ago
```


### Borrar los Runners

``` bash
$ docker stack ls
NAME                SERVICES            ORCHESTRATOR
actions             1                   Swarm

$ docker stack rm actions
Removing service actions_runner
Removing network actions_default

$ docker stack ps -f "desired-state=running" actions
nothing found in stack: actions
```




## Swarm y Contenedores Privilegiados

En **Docker Swarm** no permite el mode privilegiado y cuando arrancamos por
ejemplo el contenedor docker:dind no funciona porque es requisito imprescindible.

Si revisamos el error que sale es :

``` bash
$ docker service logs actions_dockerd-dd
actions_dockerd-dd.1.udzct3gspql0@worker02    | mount: permission denied (are you root?)
actions_dockerd-dd.1.udzct3gspql0@worker02    | Could not mount /sys/kernel/security.
actions_dockerd-dd.1.udzct3gspql0@worker02    | AppArmor detection and --privileged mode might break.

```

Para poder hacer que funcione DockerInDocker con dockerSwarm deberíamo
utilizar una instalación [rootless](https://docs.docker.com/engine/security/rootless/)
