# Makefile helper for the python-helloworld exercise


IMAGE := python-helloworld
TAG := local
IMAGE_FULL := $(IMAGE):$(TAG)
CONTAINER_NAME := python-helloworld-container
SCRIPT := ./run_docker.sh

.PHONY: help build build-no-cache run run-detached stop logs list rm-container rm-image tag clean


help:
	@echo "Makefile targets for python-helloworld (simple wrappers)"
	@echo
	@echo "  make build            # Build image ($(IMAGE_FULL))"
	@echo "  make build-no-cache   # Build image without cache"
	@echo "  make run [ARGS=...] [TAG=<tag>]  # Build (if needed) and run container; pass flags to script via ARGS"
	@echo "                       # Example: make run TAG=dev ARGS='--no-cache'"
	@echo "                       # Default TAG is '$(TAG)' (you can override: make run TAG=dev)"
	@echo "  make run-detached     # Alias for make run"
	@echo "  make stop             # Stop and remove container"
	@echo "  make logs             # Follow container logs"
	@echo "  make list             # List containers and images"
	@echo "  make rm-container RM_CONTAINER=<name|id> [FORCE=1]  # Remove container (use FORCE=1 to skip confirm)"
	@echo "  make rm-image RM_IMAGE=<name|id> [FORCE=1]          # Remove image (use FORCE=1 to skip confirm)"
	@echo "  make tag TAG_NAME=<tag>  # Tag the built image as $(IMAGE):<tag>"
	@echo "  make clean            # Remove the local image ($(IMAGE_FULL))"


build:
	@$(SCRIPT) --build-only

build-no-cache:
	@$(SCRIPT) --no-cache --build-only


run: build
	@# Forward ARGS to script and tag the image with $(TAG) (override TAG via 'make run TAG=dev')
	@$(SCRIPT) $(ARGS) --tag $(TAG)

run-detached: run

stop:
	@echo "Stopping and removing container $(CONTAINER_NAME) if exists..."
	-@docker stop $(CONTAINER_NAME) >/dev/null 2>&1 || true
	-@docker rm $(CONTAINER_NAME) >/dev/null 2>&1 || true
	@echo "Done."

logs:
	@docker logs -f $(CONTAINER_NAME)

list:
	@$(SCRIPT) --list


# Allow skipping confirmation by passing FORCE=1 (will forward --force to the script)
FORCE_FLAG :=
ifeq ($(FORCE),1)
FORCE_FLAG := --force
endif

rm-container:
	@if [ -z "$(RM_CONTAINER)" ]; then echo "Usage: make rm-container RM_CONTAINER=<name|id> [FORCE=1]"; exit 1; fi
	@$(SCRIPT) --rm-container $(RM_CONTAINER) $(FORCE_FLAG)


rm-image:
	@if [ -z "$(RM_IMAGE)" ]; then echo "Usage: make rm-image RM_IMAGE=<name|id> [FORCE=1]"; exit 1; fi
	@$(SCRIPT) --rm-image $(RM_IMAGE) $(FORCE_FLAG)

tag:
	@if [ -z "$(TAG_NAME)" ]; then echo "Usage: make tag TAG_NAME=<tag>"; exit 1; fi
	@$(SCRIPT) --tag $(TAG_NAME)

clean:
	-@docker rmi -f $(IMAGE_FULL) >/dev/null 2>&1 || true
	@echo "Cleaned local image $(IMAGE_FULL) (if present)"
