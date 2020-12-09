# jmms_gha_runners_controler_arm
Github Actions Controler en ARM64 . Nos permitirá ejecutar Acciones en nuestro cluster K3s en Rasberry

En este proyecto se revisa como adaptar [summerwind/actions-runner-controller](https://github.com/summerwind/actions-runner-controller) para poder ejecutar acciones en un cluster Raspberry donde tenemos montado k3s.

# Notas instalación:

## cer-manager

Nada que añadir, se instala tal y como se explica en el proyecto.

## preparar github app

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

## actions-runner-controller

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

## Crear runner para probar que todo funciona correctamente.

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
