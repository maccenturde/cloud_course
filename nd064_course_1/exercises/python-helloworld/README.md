# Python Helloworld (Flask) — Dockerized

> A small, self-contained example showing a Flask app with endpoints, logging and a helper script to build/run the Docker image.

---

## Table of Contents

- [Description](#description)
- [Quick start (Docker)](#quick-start-docker)
- [Using the helper script](#using-the-helper-script)
- [Endpoints](#endpoints)
- [Logs & debugging](#logs--debugging)
- [Troubleshooting](#troubleshooting)
- [Next steps](#next-steps)

---

## Description

This directory contains a minimal Flask application and the necessary files to run it in Docker:

- `app.py`: the Flask app (three routes: `/`, `/status`, `/metrics`).
- `Dockerfile`: instructions to build the image.
- `run_docker.sh`: a helper script to build, run and manage the image/container.
- `Makefile`: convenient shortcuts for common tasks (build, run, logs, stop, etc.).

The app is intended for local exercises and demos.

## Quick start (Docker)

Build and run (default behavior):

```bash
./run_docker.sh
```

This builds the image `python-helloworld:local` and starts a container named `python-helloworld-container` exposing port `5000`.

Build without cache:

```bash
./run_docker.sh --no-cache
```

Use a custom image name:tag and remove an existing container if present:

```bash
./run_docker.sh --image myname/helloworld:dev --rm-old
```

Tag the built image with an additional tag:

```bash
./run_docker.sh --tag latest
```

Build-only / run-only:

```bash
./run_docker.sh --build-only
./run_docker.sh --run-only
```

## Using the helper script

Main options (see `./run_docker.sh --examples` for more):

- `--no-cache` : build without cache
- `--image NAME:TAG` : use a specific image name:tag
- `--rm-old` : remove a container with the same name before running
- `--build-only` / `--run-only` : only build or only run
- `--tag TAG` : add an extra tag to the built image
- `--list` : show containers and images (no build/run)
- `--rm-container <id|name>` : remove a container (asks for confirmation unless `--force`)
- `--rm-image <id|name>` : remove an image (asks for confirmation unless `--force`)
- `--force` : skip confirmation for removals

You can also use the `Makefile` shortcuts (`make build`, `make run`, `make logs`, ...). Example:

```bash
# Build and run via make, tagging the image as 'dev'
make run TAG=dev ARGS='--no-cache'
```

## Endpoints

The app exposes three endpoints (see `app.py`):

- `GET /` — returns plain text `Hello World!`.

```bash
curl -i http://localhost:5000/
```

- `GET /status` — returns JSON indicating health:

```json
{"result": "OK - healthy"}
```

Example:

```bash
curl -s http://localhost:5000/status | jq
```

- `GET /metrics` — returns JSON with example metrics:

```json
{"status":"success","code":0,"data":{"UserCount":140,"UserCountActive":23}}
```

Example:

```bash
curl -s http://localhost:5000/metrics | jq
```

> Note: values returned by `/metrics` are static sample data for demonstration only.

## Logs & debugging

The application writes logs to `app.log` (inside the container's working directory) and captures Werkzeug/request logs.

Follow container logs in real time:

```bash
docker logs -f python-helloworld-container
```

Inspect `app.log` directly inside the container:

```bash
docker exec -it python-helloworld-container tail -f /app/app.log
```

## Troubleshooting

- Docker permission denied (socket access): if you see errors about `/var/run/docker.sock`:

  - Run the script with `sudo`, or add your user to the `docker` group:

    ```bash
    sudo usermod -aG docker $USER
    # log out and back in for group changes to take effect
    ```

- If the app is not reachable at port 5000, verify the container is running:

```bash
docker ps -a
```

## Next steps / ideas

- Rename `run_docker.sh` to a shorter name if desired (already done in this repo).
- Add a `dev` target to the `Makefile` that mounts source code for live development.
- Add tests and CI to validate the app and image builds.

---

If you want, I can commit this English README now (I will not push to remote unless you ask). Would you like me to commit it? If yes, tell me the commit message to use or I can use a default message.
