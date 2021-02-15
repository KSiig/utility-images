GIT_HASH_SHORT ?= $(shell git log --format="%h" -n 1)

REPO_OWNER ?= ksiig
DOCKER_REGISTRY ?= ghcr.io
DOCKER_IMAGE ?= pipeline-images
DOCKER_IMAGE_NAME ?= ${DOCKER_REGISTRY}/${REPO_OWNER}/${DOCKER_IMAGE}
DOCKER_LABEL_SOURCE ?= https://github.com/${REPO_OWNER}/${DOCKER_IMAGE}

CR_PAT ?=
DOCKERFILES_FOLDER ?= dockerfiles
BUILD_ARGS_DOCKERFILE ?= ${DOCKERFILES_FOLDER}/Dockerfile
BUILD_ARGS_NAME ?= base
BUILD_ARGS_TAG ?= ${BUILD_ARGS_NAME}-${GIT_HASH_SHORT}
BUILD_ARGS_RELEASE_TAG ?= ${BUILD_ARGS_NAME}-latest
BUILD_ARGS_FROM_IMAGE ?= ${DOCKER_IMAGE_NAME}
BUILD_ARGS_FROM_TAG ?= ${BUILD_ARGS_RELEASE_TAG}

DOCKER_WRAPPER_IMAGE ?= ${DOCKER_IMAGE_NAME}

# Define colors to use in print statements
BLACK ?= \033[0;30m
RED ?= \033[0;31m
GREEN ?= \033[0;32m
BROWN ?= \033[0;33m
BLUE ?= \033[0;34m
PURPLE ?= \033[0;35m
CYAN ?= \033[0;36m
LIGHT_GRAY ?= \033[0;37m
DARK_GRAY ?= \033[1;30m
LIGHT_RED ?= \033[1;31m
LIGHT_GREEN ?= \033[1;32m
YELLOW ?= \033[1;33m
LIGHT_BLUE ?= \033[1;34m
LIGHT_PURPLE ?= \033[1;35m
LIGHT_CYAN ?= \033[1;36m
WHITE ?= \033[1;37m
NO_COLOR ?= \033[0m

_init:
	@printf "${LIGHT_BLUE}Logging into GitHub Docker registry...${NO_COLOR}\n"
	@echo '${CR_PAT}' | docker login ${DOCKER_REGISTRY} -u KSiig --password-stdin
	@printf "${GREEN}Successfully logged into GitHub Docker registry...${NO_COLOR}\n"
.PHONY: _init

_builder: _init
	@printf "${LIGHT_BLUE}Image ${DOCKER_IMAGE_NAME}:${BUILD_ARGS_TAG} being built...${NO_COLOR}\n"
	@docker build --force-rm --compress \
		--cache-from ${DOCKER_IMAGE_NAME}:${BUILD_ARGS_RELEASE_TAG} \
		--build-arg BUILD_ARGS_FROM_IMAGE=${BUILD_ARGS_FROM_IMAGE} \
		--build-arg BUILD_ARGS_FROM_TAG=${BUILD_ARGS_FROM_TAG} \
		--build-arg REPO_OWNER=${REPO_OWNER} \
		--build-arg REPO_NAME=${DOCKER_IMAGE} \
		--label org.opencontainers.image.source=${DOCKER_LABEL_SOURCE} \
		-t ${DOCKER_IMAGE_NAME}:${BUILD_ARGS_TAG} \
		-f ${BUILD_ARGS_DOCKERFILE} .
	@printf "${GREEN}Image ${DOCKER_IMAGE_NAME}:${BUILD_ARGS_TAG} built!${NO_COLOR}\n"
.PHONY: _builder

_pusher: _init
	@printf "${LIGHT_BLUE}Image ${DOCKER_IMAGE_NAME}:${BUILD_ARGS_TAG} being pushed...${NO_COLOR}\n"
	@docker push ${DOCKER_IMAGE_NAME}:${BUILD_ARGS_TAG}
	@printf "${GREEN}Image ${DOCKER_IMAGE_NAME}:${BUILD_ARGS_TAG} pushed!${NO_COLOR}\n"
.PHONY: _pusher

_releaser: _init
	@printf "${LIGHT_BLUE}Releasing ${DOCKER_IMAGE_NAME}:${BUILD_ARGS_RELEASE_TAG}...${NO_COLOR}\n"
	docker pull ${DOCKER_IMAGE_NAME}:${BUILD_ARGS_TAG}
	@docker tag ${DOCKER_IMAGE_NAME}:${BUILD_ARGS_TAG} ${DOCKER_IMAGE_NAME}:${BUILD_ARGS_RELEASE_TAG}
	@docker push ${DOCKER_IMAGE_NAME}:${BUILD_ARGS_RELEASE_TAG}
	@printf "${GREEN}Released ${DOCKER_IMAGE_NAME}:${BUILD_ARGS_RELEASE_TAG}!${NO_COLOR}\n"
.PHONY: _releaser

build_base:
	$(MAKE) _builder
.PHONY: build_base

push_base:
	$(MAKE) _pusher
.PHONY: push_base

release_base:
	$(MAKE) _releaser && \
	$(MAKE) _releaser -e BUILD_ARGS_RELEASE_TAG="latest"
.PHONY: release_base

# Actual targets
build_%:
	$(MAKE) _builder \
		-e BUILD_ARGS_TAG="${GIT_HASH_SHORT}" \
		-e DOCKER_IMAGE="$*" \
		-e BUILD_ARGS_DOCKERFILE="${DOCKERFILES_FOLDER}/Dockerfile.$*"

push_%:
	$(MAKE) _pusher \
		-e BUILD_ARGS_TAG="$*-${GIT_HASH_SHORT}"

release_%:
	$(MAKE) _releaser \
		-e BUILD_ARGS_TAG="$*-${GIT_HASH_SHORT}" \
		-e DOCKER_IMAGE="$*"

docker_%:
	@docker run --rm \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v $(shell pwd):/app \
	-w /app \
	-e CR_PAT=${CR_PAT} \
	${DOCKER_WRAPPER_IMAGE} $(MAKE) $*