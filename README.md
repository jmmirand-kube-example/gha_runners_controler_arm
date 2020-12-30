<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Github Actions para las Raspberrys](#github-actions-para-las-raspberrys)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Github Actions para las Raspberrys

Se estudia como sacar provecho a nuestras Raspberrys con Github Actions
de Github.com.

Para ello busco iniciativas y artículos disponibles que nos puedan ayudar a
integrar y entender como funciona Github Actions.


<!--ts-->



   * [Docker Github Runners](./doc/01_docker-runner.md#docker-github-runners)
      * [Crear Imagen Docker para el Runner](./doc/01_docker-runner.md#crear-imagen-docker-para-el-runner)
      * [Probar Docker Runners](./doc/01_docker-runner.md#probar-docker-runners)
         * [Arrancar runner con cliente docker instalado.](./doc/01_docker-runner.md#arrancar-runner-con-cliente-docker-instalado)

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

<!-- Added by: jmmirand, at: Sun Dec 27 08:49:05 CET 2020 -->

<!--te-->
