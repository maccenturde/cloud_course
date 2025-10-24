## Python Helloworld (Flask) - Dockerized

Un pequeño proyecto de ejemplo que contiene una aplicación Flask ligera y scripts para construir y ejecutar la imagen Docker localmente.

Características principales
- Aplicación Flask simple que expone el puerto 5000
- Dockerfile listo para construir una imagen reproducible
- Script `run_docker_exec.sh` para construir, ejecutar y administrar la imagen/contenedor desde la línea de comandos

¿Qué hace la aplicación?

La aplicación es una pequeña API Flask con tres rutas principales:

- `/` : devuelve un simple texto "Hello World!" y escribe un registro de información indicando que la petición principal fue exitosa.

- `/status` : devuelve JSON con el estado de la aplicación, por ejemplo:

  ```json
  {"result": "OK - healthy"}
  ```

- `/metrics` : devuelve JSON con métricas simuladas en el formato:

  ```json
  {"status":"success","code":0,"data":{"UserCount":140,"UserCountActive":23}}
  ```

Además, la app configura logging que escribe a `app.log` (incluye logs de la propia aplicación y los logs de Werkzeug/requests). Al ejecutar la app dentro del contenedor, revisa `app.log` o usa `docker logs -f <container>` para ver la salida en tiempo real.

Requisitos
- Docker instalado en el host
- Opcional: añadir tu usuario al grupo `docker` o usar `sudo` para ejecutar comandos Docker

Cómo usar

1) Construir y ejecutar (flujo por defecto)

   ./run_docker_exec.sh

   Esto construye la imagen por defecto `python-helloworld:local` y arranca un contenedor llamado `python-helloworld-container` mapeando el puerto 5000.

2) Forzar reconstrucción sin cache

   ./run_docker_exec.sh --no-cache

3) Usar nombre/etiqueta de imagen personalizado

   ./run_docker_exec.sh --image myname/helloworld:dev --rm-old

4) Etiquetar adicionalmente la imagen construida

   ./run_docker_exec.sh --tag latest

5) Solo construir o solo ejecutar

   ./run_docker_exec.sh --build-only
   ./run_docker_exec.sh --run-only

Administración de contenedores e imágenes

# Python Helloworld (Flask) — Dockerized

> Ejemplo pequeño y auto-contenido que muestra una app Flask con endpoints, logging y un helper para construir/ejecutar la imagen Docker.

---

## Tabla de contenidos

- [Descripción](#descripción)
- [Quick start (Docker)](#quick-start-docker)
- [Uso del script `run_docker_exec.sh`](#uso-del-script-rundocker_execsh)
- [Endpoints](#endpoints)
- [Logs y debugging](#logs-y-debugging)
- [Solución de problemas](#solución-de-problemas)
- [Siguientes pasos](#siguientes-pasos)

---

## Descripción

Esta carpeta contiene una pequeña aplicación Flask y todo lo necesario para ejecutarla en Docker:

- `app.py`: la aplicación Flask (3 rutas: `/`, `/status`, `/metrics`).
- `Dockerfile`: instrucciones para construir la imagen basada en Python.
- `run_docker_exec.sh`: script helper para construir, ejecutar y administrar la imagen/contenedor.

La app está diseñada para ser usada como ejemplo en ejercicios o demos locales.

## Quick start (Docker)

Construir y ejecutar (comportamiento por defecto):

```bash
./run_docker.sh
```

Esto crea la imagen `python-helloworld:local` y arranca un contenedor llamado `python-helloworld-container` exponiendo el puerto `5000`.

Construcción sin cache:

```bash
./run_docker.sh --no-cache
```

Usar un nombre/etiqueta personalizados y eliminar contenedor previo si existe:

```bash
./run_docker.sh --image myname/helloworld:dev --rm-old
```

Etiquetar adicionalmente la imagen construida:

```bash
./run_docker.sh --tag latest
```

Solo construir / solo ejecutar:

```bash
./run_docker.sh --build-only
./run_docker.sh --run-only
```

## Uso del script `run_docker_exec.sh`

Opciones principales:

- `--no-cache` : Build sin cache
- `--image NAME:TAG` : Usar imagen y tag personalizados
- `--rm-old` : Si existe un contenedor con el mismo nombre, eliminarlo antes de arrancar
- `--build-only` / `--run-only` : Solo construir o solo ejecutar
- `--tag TAG` : Aplicar una etiqueta adicional a la imagen construida
- `--list` : Mostrar contenedores e imágenes (no hace build ni run)
- `--rm-container <id|name>` : Eliminar un contenedor (pregunta confirmación)
- `--rm-image <id|name>` : Eliminar una imagen (pregunta confirmación)
- `--force` : Omitir la confirmación al eliminar

Ejemplos rápidos:

```bash
# Listar contenedores e imágenes
./run_docker.sh --list

# Eliminar contenedor (pedirá confirmación)
./run_docker.sh --rm-container python-helloworld-container

# Forzar sin confirmación
./run_docker.sh --rm-container python-helloworld-container --force
```

## Endpoints

La aplicación expone tres rutas principales (basado en `app.py`):

- `GET /` — Respuesta: texto "Hello World!"

```bash
curl -i http://localhost:5000/
# HTTP/1.1 200 OK
# Hello World!
```

- `GET /status` — Respuesta JSON indicando salud:

```json
{"result": "OK - healthy"}
```

Ejemplo curl:

```bash
curl -s http://localhost:5000/status | jq
```

- `GET /metrics` — Respuesta JSON con métricas simuladas:

```json
{"status":"success","code":0,"data":{"UserCount":140,"UserCountActive":23}}
```

Ejemplo curl:

```bash
curl -s http://localhost:5000/metrics | jq
```

> Nota: los valores en `/metrics` son estáticos y sirven solo como ejemplo.

## Logs y debugging

La aplicación configura logging hacia el fichero `app.log` (archivo en el working directory de la app dentro del contenedor). También captura logs de Werkzeug (requests).

Ver logs del contenedor (en tiempo real):

```bash
docker logs -f python-helloworld-container
```

Si quieres inspeccionar `app.log` directamente desde el contenedor:

```bash
docker exec -it python-helloworld-container tail -f /app/app.log
```

## Solución de problemas

- Permission denied al usar Docker: si ves mensajes relacionados con `/var/run/docker.sock`:
  - Ejecuta con `sudo` o añade tu usuario al grupo `docker`:

```bash
sudo usermod -aG docker $USER
# luego cierra sesión y vuelve a entrar
```

- Si la app no responde en el puerto 5000, comprueba que el contenedor está corriendo:

```bash
docker ps -a
```

## Siguientes pasos / ideas

- Renombrar `run_docker_exec.sh` a `run_docker.sh` para simplificar el nombre.
- Añadir un `Makefile` con objetivos `make build`, `make run`, `make clean`.
- Incorporar tests simples y un `Dockerfile` multi-stage si se añaden dependencias compiladas.

---
