<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Probar Docker Runners](#probar-docker-runners)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


# Probar Docker Runners


Una vez arrancado el runner, ya puede ser usado desde cualquier repositorio que
esté en la organización.

Creamos un repo vacío y añadimos el workflows

Tenemos que asegurarnos que el tag que usamos es con el que hemos arrancado el
runner

``` yaml
# This is a basic workflow to help you get started with Actions

name: CI-docker-self-hosted

# Controls when the action will run.
on: push

jobs:
  my_job_docker_self_hosted:
    runs-on: docker-runner
    steps:
      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      - uses: actions/checkout@v2
      # Runs a single command using the runners shell
      - name: Run a multi-line script
        run: |
          docker version
          echo Add other actions to build,
          echo test, and deploy your project.
          ls -lrt
```
