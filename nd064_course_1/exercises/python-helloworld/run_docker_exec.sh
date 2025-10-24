#!/usr/bin/env bash
set -euo pipefail

# run_docker_exec.sh - helper to build and run the Docker image for this Flask app.
# Includes usage examples and an extra tag option.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

IMAGE_NAME="python-helloworld"
TAG="local"
EXTRA_TAG=""
CONTAINER_NAME="python-helloworld-container"
NO_CACHE=0
BUILD_ONLY=0
RUN_ONLY=0
RM_OLD=0
LIST=0
RM_CONTAINER=""
RM_IMAGE=""
FORCE=0

usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  --no-cache       Build image without cache
  --image NAME:TAG Use specific image name and tag (overrides defaults)
  --rm-old         If a container with the same name exists, remove it before running
  --build-only     Only build the image
  --run-only       Only run the container (assumes image exists)
  --examples       Show usage examples
  --tag TAG        Also tag the built image with TAG (e.g. 'latest')
  --list           Show docker containers and images (no build/run)
  --rm-container X Remove container named or with id X (requires confirmation unless --force)
  --rm-image X     Remove image named or with id X (requires confirmation unless --force)
  --force          Skip confirmation for removals
  -h, --help       Show this help

Defaults:
  image: ${IMAGE_NAME}:${TAG}
  container name: ${CONTAINER_NAME}
  Exposes port 5000 -> 5000
EOF
}

examples() {
  cat <<'EOG'
Examples:

  # Build and run (default)
  ./run_docker_exec.sh

  # Force rebuild without cache
  ./run_docker_exec.sh --no-cache

  # Use custom image name:tag and remove an old container with same name
  ./run_docker_exec.sh --image myname/helloworld:dev --rm-old

  # Also tag the built image as 'latest'
  ./run_docker_exec.sh --tag latest

  # Only build the image
  ./run_docker_exec.sh --build-only

  # Only run an existing image
  ./run_docker_exec.sh --run-only

  # List containers and images
  ./run_docker_exec.sh --list

  # Remove a container (will ask for confirmation)
  ./run_docker_exec.sh --rm-container python-helloworld-container

  # Remove an image (will ask for confirmation)
  ./run_docker_exec.sh --rm-image python-helloworld:local

EOG
}

while [[ ${#} -gt 0 ]]; do
  case "$1" in
    --no-cache) NO_CACHE=1; shift ;;
    --rm-old) RM_OLD=1; shift ;;
    --build-only) BUILD_ONLY=1; shift ;;
    --run-only) RUN_ONLY=1; shift ;;
    --image)
      if [[ -n ${2:-} ]]; then
        IFS=":" read -r IMAGE_NAME TAG <<< "$2"
        shift 2
      else
        echo "--image requires an argument like name:tag" >&2; exit 1
      fi
      ;;
    --tag)
      if [[ -n ${2:-} ]]; then
        EXTRA_TAG="$2"
        shift 2
      else
        echo "--tag requires an argument like 'latest'" >&2; exit 1
      fi
      ;;
    --list)
      LIST=1; shift ;;
    --rm-container)
      if [[ -n ${2:-} ]]; then
        RM_CONTAINER="$2"; shift 2
      else
        echo "--rm-container requires a container name or id" >&2; exit 1
      fi
      ;;
    --rm-image)
      if [[ -n ${2:-} ]]; then
        RM_IMAGE="$2"; shift 2
      else
        echo "--rm-image requires an image name or id" >&2; exit 1
      fi
      ;;
    --force)
      FORCE=1; shift ;;
    --examples) examples; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1 ;;
  esac
done

if ! command -v docker >/dev/null 2>&1; then
  echo "docker not found in PATH. Please install Docker and try again." >&2
  exit 1
fi

# If user requested listing or removals, handle them now and exit (do not build/run)
if [[ ${LIST} -eq 1 ]]; then
  echo "Containers (docker ps -a):"
  docker ps -a
  echo
  echo "Images (docker images):"
  docker images
  exit 0
fi

if [[ -n "${RM_CONTAINER}" ]]; then
  if [[ ${FORCE} -eq 0 ]]; then
    read -r -p "Remove container ${RM_CONTAINER}? [y/N] " ans
    case "${ans}" in
      [yY]) ;;
      *) echo "Aborted."; exit 0 ;;
    esac
  fi
  echo "Removing container ${RM_CONTAINER}..."
  docker rm -f "${RM_CONTAINER}"
  echo "Done."
  exit 0
fi

if [[ -n "${RM_IMAGE}" ]]; then
  if [[ ${FORCE} -eq 0 ]]; then
    read -r -p "Remove image ${RM_IMAGE}? [y/N] " ans
    case "${ans}" in
      [yY]) ;;
      *) echo "Aborted."; exit 0 ;;
    esac
  fi
  echo "Removing image ${RM_IMAGE}..."
  docker rmi -f "${RM_IMAGE}"
  echo "Done."
  exit 0
fi

FULL_IMAGE="${IMAGE_NAME}:${TAG}"

if [[ ${RUN_ONLY} -eq 1 && ${BUILD_ONLY} -eq 1 ]]; then
  echo "Can't use --build-only and --run-only together" >&2; exit 1
fi

if [[ ${RM_OLD} -eq 1 ]]; then
  if docker ps -a --format '{{.Names}}' | grep -xq "${CONTAINER_NAME}"; then
    echo "Removing existing container ${CONTAINER_NAME}..."
    docker rm -f "${CONTAINER_NAME}"
  fi
fi

if [[ ${RUN_ONLY} -eq 0 ]]; then
  echo "Building image ${FULL_IMAGE}..."
  BUILD_ARGS=()
  if [[ ${NO_CACHE} -eq 1 ]]; then
    BUILD_ARGS+=(--no-cache)
  fi
  docker build "${BUILD_ARGS[@]}" -t "${FULL_IMAGE}" .
  echo "Build finished: ${FULL_IMAGE}"
  if [[ -n "${EXTRA_TAG}" ]]; then
    echo "Tagging image ${FULL_IMAGE} as ${IMAGE_NAME}:${EXTRA_TAG}..."
    docker tag "${FULL_IMAGE}" "${IMAGE_NAME}:${EXTRA_TAG}"
    echo "Tagged: ${IMAGE_NAME}:${EXTRA_TAG}"
  fi
  if [[ ${BUILD_ONLY} -eq 1 ]]; then
    echo "Build-only requested; exiting."; exit 0
  fi
fi

echo "Running container ${CONTAINER_NAME} from image ${FULL_IMAGE}..."
# If a container with the same name exists, stop/remove it first
if docker ps -a --format '{{.Names}}' | grep -xq "${CONTAINER_NAME}"; then
  echo "Container with name ${CONTAINER_NAME} already exists. Stopping and removing..."
  docker rm -f "${CONTAINER_NAME}"
fi

docker run -d --name "${CONTAINER_NAME}" -p 5000:5000 "${FULL_IMAGE}"

echo "Container started. To view logs: docker logs -f ${CONTAINER_NAME}"
echo "To stop: docker stop ${CONTAINER_NAME} && docker rm ${CONTAINER_NAME}"

exit 0
