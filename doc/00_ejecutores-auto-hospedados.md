<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Ejecutores auto hospedados.](#ejecutores-auto-hospedados)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Ejecutores auto hospedados.

Github nos permite ejecutar flujos de trabajo con Github Actions. Los pasos los
ejecuta lo que llaman runners ( equivalentes a esclavos en Jenkins)

Los runners pueden ser gestionados por el propio gihtub. O bien podemos tenerlo
en nuestra infraestructura github los denomina runners **self-hosted**.

Si queremos trabajar con Raspberry, debemos trabajar con runners self-hosted,
github proporciona runner en arquitecturas mac/windows/linux pero no ARM.

Existe la capacidad de realizar contenedores con arq=ARM para el mundo raspberry
usando **dockerx** usando los runners del propio github.

Nosotros nos centraremos en dar la posibilidad crear flujos de trabajo
que puedan ejecutar 100% en dispositivos ARM.


**Para más información**

 * [Alojar tus propios corredores](https://docs.github.com/es/free-pro-team@latest/actions/hosting-your-own-runners)
