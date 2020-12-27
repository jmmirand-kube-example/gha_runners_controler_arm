<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Uso de actions-runner-controller](#uso-de-actions-runner-controller)
- [Instalación del Actions Controller en k3s](#instalaci%C3%B3n-del-actions-controller-en-k3s)
  - [Cert-Manager](#cert-manager)
  - [Githubapp](#githubapp)
  - [Modificaciones a realizar en el proyecto actions-runner-controller](#modificaciones-a-realizar-en-el-proyecto-actions-runner-controller)
  - [Test del Runner](#test-del-runner)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->
## Uso de actions-runner-controller

Revisar el proyecto [summerwind/actions-runner-controller](https://github.com/summerwind/actions-runner-controller) para poder ejecutar acciones en un cluster Raspberry donde tenemos montado k3s.

Midificaremos la instalación para adaptar Github Actions Controller a la arquitectura ARM64. Nos permitirá ejecutar Acciones en nuestro cluster Raspberry K3s.



## Instalación del Actions Controller en k3s

Los pasos de instalación seguimos los del propio repositorio [summerwind/actions-runner-controller](https://github.com/summerwind/actions-runner-controller).  

Destacar algunos problemas encontrados en ARM.

### Cert-Manager

Nada que añadir, se instala tal y como se explica en el proyecto.

### Githubapp

  * Crear la aplicación github-apps
  * Las urls que nos piden añadimos la propia de la organización github.
  * Permisos github apps.
    - Repository: Administration (read/write)
    - Repository: Actions (read)
    - Organization: Self-hosted runners (read/write)
  * Instalamos la aplicación en la organización
    - appId: Se obtiene del panel de Github.app
    - InstalationID : Se obtiene de la instalación de la Githubapp
    - Fichero Private Key : Se descarga de la instalación de la app.
```
kubectl create secret generic controller-manager \
    -n actions-runner-system \
     --from-literal=github_app_id={{APP_ID}} \
     --from-literal=github_app_installation_id={{INSTALLATION_ID}} \
     --from-file=github_app_private_key={{PATH_TO_PRIVATE_KEY}}
```

### Modificaciones a realizar en el proyecto actions-runner-controller

  * Descargamos el fichero con el manifest **Create GitHub Apps on your organization**


``` bash
$ curl -o actions-runner-controller.yaml https://github.com/summerwind/actions-runner-controller/releases/latest/download/actions-runner-controller.yaml
```

  * El pod que trea esta implementación de [kube_rabac_proxy](https://console.cloud.google.com/gcr/images/kubebuilder/GLOBAL/kube-rbac-proxy?gcrImageListsize=30) no está en ARM64. Buscamos otra que nos de la misma funcionalidad

  * Usaremos  [carlosedp/kube-rbac-proxy:v0.5.0](https://hub.docker.com/r/carlosedp/kube-rbac-proxy/tags?page=1&ordering=last_updated)

  * Ejecutamos
      * Aplicamos el fichero yaml creado y después que
      * Ya se ha creado el namespace creamos el secreto.
      * Comprobamos que están ejecutando los pods creados

```
kubectl apply -f actions-runner-controler.yaml

kubectl create secret generic controller-manager \
   -n actions-runner-system \
   --from-literal=github_app_id=92101 \
   --from-literal=github_app_installation_id=13445429 \
   --from-file=github_app_private_key=/Users/jmmirand/Downloads/jmmactions-runner-controler.2020-12-09.private-key.pem

kubectl get pod -n actions-runner-system
```

### Test del Runner

``` yaml

apiVersion: actions.summerwind.dev/v1alpha1
kind: Runner
metadata:
  name: example-org-runner
spec:
  organization: jmmirand-kube-example

```

``` bash
 $ kubectl apply -f runner.yaml
 $ kubectl get runners
 $ kubectl get pods
```
