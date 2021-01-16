<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Tabla de Contenidos](#tabla-de-contenidos)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

GitHub Actions permite crear flujos de trabajo (workflows) que se pueden utilizar para compilar, probar y desplegar código, dando la posibilidad de crear flujos de integración y despliegue continuo dentro del propio repositorio de git. Los flujos de trabajo tienen que contener al menos un job

Los flujos de trabajo tienen que contener al menos un job. Estos incluyen una serie de pasos que ejecutan tareas individuales que pueden ser acciones o comandos. Un flujo de trabajo puede comenzar por distintos eventos que suceden dentro de GitHub, como un push al repositorio o un pull request.

Los jobs se ejecutan en una infraestructura llamada runners. Estos pueden ser de varios tipos Windows, MacOs y Linux. Esos a su vez los puede proporcionar Github o bien los podemos tener alojado en infraestructura local.

En este artículo se estudia como sacar provecho a nuestras Raspberrys creando runners que puedan ser usados
desde github actions. Repasaremos documentación oficial, iniciativas y artículos publicados que nos
ayuden a integrar y entender como funciona.



# Tabla de Contenidos
<!--ts-->

   * [Ejecutores auto hospedados.](./doc/00_ejecutores-auto-hospedados.md#ejecutores-auto-hospedados)

   * [Docker Github Runners](./doc/01_docker-runner.md#docker-github-runners)
      * [Crear Imagen Docker para el Runner](./doc/01_docker-runner.md#crear-imagen-docker-para-el-runner)
      * [Probar Docker Runners](./doc/01_docker-runner.md#probar-docker-runners)
         * [Arrancar runner con cliente docker instalado.](./doc/01_docker-runner.md#arrancar-runner-con-cliente-docker-instalado)

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

<!-- Added by: jmmirand, at: date +%d-%m-%Y-->


<!--te-->
