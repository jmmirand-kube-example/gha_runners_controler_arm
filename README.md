
# Integración entre Github Actions y Rasberrys

GitHub Actions permite crear flujos de trabajo (workflows) que se pueden utilizar para compilar, probar y desplegar código, dando la posibilidad de crear flujos de integración y despliegue continuo dentro del propio repositorio de git.

Los flujos de trabajo tienen que contener al menos un job. Estos incluyen una serie de pasos que ejecutan tareas individuales que pueden ser acciones o comandos. Un flujo de trabajo puede comenzar por distintos eventos que suceden dentro de GitHub, como un push al repositorio o un pull request.

Los jobs se ejecutan en un VM o Host que llevan instalado un agente llamado runners. Github proporciona integrada en su solución un conjunto de Runners dependiendo de la VM o Host sea Windows, MacOs y Linux.
También existe la posibilidad de ejecutar en nuestras VMS, Hosts, Rasapberrys, PCs los pasos de los jobs
y github los llama [Runner Self Hosted](https://docs.github.com/es/free-pro-team@latest/actions/hosting-your-own-runners)

En este artículo se estudia como sacar provecho a nuestras Raspberrys instalando runners para ser usado
desde github actions. Repasaremos la documentación oficial, iniciativas y artículos públicos que nos ayudarán a entender como funciona.


.



<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

<!--ts-->



   * [Github Runners con Docker](./doc/01_docker-runner.md#github-runners-con-docker)
      * [Crear DockerFile y construción de la imágen.](./doc/01_docker-runner.md#crear-dockerfile-y-construción-de-la-imágen)
         * [Basar la imagen docker en ubuntu](./doc/01_docker-runner.md#basar-la-imagen-docker-en-ubuntu)
         * [Instalación Utilidades](./doc/01_docker-runner.md#instalación-utilidades)
         * [Instalación Docker Deamon](./doc/01_docker-runner.md#instalación-docker-deamon)
         * [Instalación del agente github](./doc/01_docker-runner.md#instalación-del-agente-github)
         * [Copiar ENTRYPOINT](./doc/01_docker-runner.md#copiar-entrypoint)
      * [Entrypoint start.sh](./doc/01_docker-runner.md#entrypoint-startsh)
      * [Build imagen Docker](./doc/01_docker-runner.md#build-imagen-docker)
      * [Probar Docker Runners](./doc/01_docker-runner.md#probar-docker-runners)

   * [Github runner con un docker in docker](./doc/02_runner_basado_dind.md#github-runner-con-un-docker-in-docker)
      * [Instalar Docker Deamon y Docker Client](./doc/02_runner_basado_dind.md#instalar-docker-deamon-y-docker-client)
      * [Arrancar Runner &amp; Docker in Docker (Server)](./doc/02_runner_basado_dind.md#arrancar-runner--docker-in-docker-server)
      * [Comprobar y chequear el Runner](./doc/02_runner_basado_dind.md#comprobar-y-chequear-el-runner)

   * [Probar Docker Runners](./doc/10_test_docker_runner.md#probar-docker-runners)

   * [Referencias](./doc/99_referencias.md#referencias)

   * [Controlador de Runner en Kubernetes ( actions-runner-controller )](./doc/actions-runner-controller-arm.md#controlador-de-runner-en-kubernetes--actions-runner-controller-)
      * [Instalación del Actions Controller en k3s](./doc/actions-runner-controller-arm.md#instalación-del-actions-controller-en-k3s)
         * [Cert-Manager](./doc/actions-runner-controller-arm.md#cert-manager)
         * [Githubapp](./doc/actions-runner-controller-arm.md#githubapp)
         * [Modificaciones a realizar en el proyecto actions-runner-controller](./doc/actions-runner-controller-arm.md#modificaciones-a-realizar-en-el-proyecto-actions-runner-controller)
         * [Test del Runner](./doc/actions-runner-controller-arm.md#test-del-runner)

      * [Arrancar Runner con Docker Compose](./doc/docker-compose-runner.md#arrancar-runner-con-docker-compose)

      * [Docker Swarm runner ( Escalabilidad Vertical )](./doc/docker-swarm-runners.md#docker-swarm-runner--escalabilidad-vertical-)
         * [Instalar el cluster](./doc/docker-swarm-runners.md#instalar-el-cluster)
         * [Borrar los Runners](./doc/docker-swarm-runners.md#borrar-los-runners)
      * [Swarm y Contenedores Privilegiados](./doc/docker-swarm-runners.md#swarm-y-contenedores-privilegiados)



Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)

<!-- Added by: jmmirand-->

<!--te-->
