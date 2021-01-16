<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Ejecutores auto hospedados.](#ejecutores-auto-hospedados)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Ejecutores auto hospedados.

Github nos permite ejecutar flujos de trabajo con Github Actions. Los nodos que
ejecutan los trabajos pueden estar en la nube y nos lo proporciona el propio
github o bien pueden estar en una infraestructura propia los que
llamaremos **self-hosted**.

Los ejecutores en la nube no son arquitectura ARM con lo cual todo lo que haga
está basado en x86 tanto para mac/windows/linux.

Lo que si que tiene Actions docker ( **dockerx** ) que permite la construcción
de imágenes en diversas arquitecturas.  Esto permite la ejecución en Raspberry.

Nosotros nos centraremos en dar la posibilidad crear flujos de trabajo
que puedan ejecutar 100% en dispositivos ARM.


**Para más información**

 * [Alojar tus propios corredores](https://docs.github.com/es/free-pro-team@latest/actions/hosting-your-own-runners)
