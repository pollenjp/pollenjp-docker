# * PARAMETERS
#   * CUDA_VERSION := 11.1.1-cudnn8-devel
#   * UBUNTU_VERSION := 18.04
#
# * cuda:9.0
#   * 9.0-devel-ubuntu16.04
#   * 9.0-cudnn7-devel-ubuntu16.04
# * cuda:9.1
#   * 9.1-devel-ubuntu16.04
# * cuda:9.2
#   * 9.2-devel-ubuntu16.04
#   * 9.2-devel-ubuntu18.04
#   * 9.2-cudnn7-devel-ubuntu18.04

DEBUG_MODE := 0  # 0 or 1
TIME_STAMP := latest
ifeq (${DEBUG_MODE}, 1)
TIME_STAMP := $(shell echo "$(shell date +%Y%m%d-%H%M%S%Z)")
endif
TARGET_NAME_BASE := pollenjp-docker
DOCKERFILE_DIR := .
USER_NAME :=

# specify
NEXUS_COMMAND_PATH :=

SHELL := /bin/bash
#.DEFAULT_GOAL := cuda11.1.1-cudnn8-devel-ubuntu18.04
.DEFAULT_GOAL := help

export

#############################
# nvidiea/cuda docker image #
#############################
# - cudnn8-devel-ubuntu18.04: <https://hub.docker.com/r/nvidia/cuda/tags?page=1&name=cudnn8-devel-ubuntu18.04&ordering=last_updated>

#########
# base1 #
#########

.PHONY : docker-build-base1-cuda11.2.2-cudnn8-devel-ubuntu18.04
docker-build-base1-cuda11.2.2-cudnn8-devel-ubuntu18.04 :  ## base1 build
	$(MAKE) docker-build-base1-template \
		CUDA_VERSION=11.2.2-cudnn8-devel \
		UBUNTU_VERSION=18.04

.PHONY : docker-build-base1-template
docker-build-base1-template :  ## base1 template
	${MAKE} docker-build-base1 \
		TARGET_NAME_BASE=${TARGET_NAME_BASE}-base1 \
		DOCKERFILE_DIR=./base1

.PHONY : docker-build-base1
docker-build-base1 :  ## base1
	docker build \
		--network=host \
		--tag "${TARGET_NAME_BASE}-cuda${CUDA_VERSION}-ubuntu${UBUNTU_VERSION}:${TIME_STAMP}" \
		--build-arg CUDA_VERSION=${CUDA_VERSION} \
		--build-arg UBUNTU_VERSION=${UBUNTU_VERSION} \
		--build-arg DOCKERFILE_DIR=${DOCKERFILE_DIR} \
		${BUILD_OPTION} \
		--file ${DOCKERFILE_DIR}/Dockerfile \
		.

.PHONY : test-docker-base1-build-and-run
test-docker-base1-build-and-run :  ## base1 build and run
	${MAKE} clean
	${MAKE} docker-build-base1-cuda11.2.2-cudnn8-devel-ubuntu18.04
	docker run \
		--rm \
		--network=test-net \
		--gpus all \
		--env LOCAL_USER_NAME=$(shell id --user --name ${USER_NAME}) \
		--env LOCAL_USER_ID=$(shell id --user ${USER_NAME}) \
		--env LOCAL_GROUP_NAME=$(shell id --group --name ${USER_NAME}) \
		--env LOCAL_GROUP_ID=$(shell id --group ${USER_NAME}) \
		--env NVIDIA_DRIVER_CAPABILITIES=all \
		--volume ${HOME}/workdir:${HOME}/workdir/ \
		--volume /media:/media \
		--name="test" \
		${TARGET_NAME_BASE}-base1-cuda11.2.2-cudnn8-devel-ubuntu18.04

#########
# base2 #
#########

.PHONY : docker-build-base2-cuda10.2-cudnn8-devel-ubuntu18.04
docker-build-base2-cuda10.2-cudnn8-devel-ubuntu18.04 :  ## base2 build
	$(MAKE) docker-build-base2 \
		CUDA_VERSION=10.2-cudnn8-devel \
		UBUNTU_VERSION=18.04

.PHONY : docker-build-base2-cuda11.1.1-cudnn8-devel-ubuntu18.04
docker-build-base2-cuda11.1.1-cudnn8-devel-ubuntu18.04 :  ## base2 build
	$(MAKE) docker-build-base2-template \
		CUDA_VERSION=11.1.1-cudnn8-devel \
		UBUNTU_VERSION=18.04

.PHONY : docker-build-base2-template
docker-build-base2-template :  ## base2 template
	${MAKE} docker-build-base2 \
		TARGET_NAME_BASE=${TARGET_NAME_BASE}-base2 \
		DOCKERFILE_DIR=./base2

.PHONY : docker-build-base2
docker-build-base2 :  ## base2
	docker build \
		--network=host \
		--tag "${TARGET_NAME_BASE}-cuda${CUDA_VERSION}-ubuntu${UBUNTU_VERSION}:${TIME_STAMP}" \
		--build-arg CUDA_VERSION=${CUDA_VERSION} \
		--build-arg UBUNTU_VERSION=${UBUNTU_VERSION} \
		--build-arg DOCKERFILE_DIR=${DOCKERFILE_DIR} \
		${BUILD_OPTION} \
		--file ${DOCKERFILE_DIR}/Dockerfile \
		.

.PHONY : test-docker-base2-build-and-run
test-docker-base2-build-and-run :  ## base2 test
	${MAKE} clean
	${MAKE} test-docker-base2-build
	${MAKE} test-docker-base2-run

.PHONY : test-docker-base2-build
test-docker-base2-build :  ## base2 test
	${MAKE} -j 2 \
		docker-build-base2-cuda10.2-cudnn8-devel-ubuntu18.04 \
		docker-build-base2-cuda11.1.1-cudnn8-devel-ubuntu18.04

.PHONY : test-docker-base2-run
test-docker-base2-run :  # base2 test
	docker run \
		--restart=always \
		--network=test-net \
		--gpus all \
		--env LOCAL_USER_ID=$(shell id --user ${USER_NAME}) \
		--env LOCAL_GROUP_ID=$(shell id --group ${USER_NAME}) \
		--env NVIDIA_DRIVER_CAPABILITIES=all \
		--volume ${HOME}/workdir:${HOME}/workdir/ \
		--volume /media:/media \
		--name="test" \
		${TARGET_NAME_BASE}-cuda11.1.1-cudnn8-devel-ubuntu18.04

###########
# network #
###########

.PHONY : create-test-docker-network
create-test-docker-network :  ## test create-test-docker-network
	docker network create \
		--driver=bridge \
		--subnet=172.19.0.0/16 \
		--gateway=172.19.255.254 \
		test-net

#########
# clean #
#########

.PHONY : clean
clean :
	-docker container stop test
	-docker container rm   test

#########
# Utils #
#########

.PHONY : help
help :
	@echo ${MAKEFILE_LIST}
	@awk \
		'BEGIN { print "==BEGIN==" } \
		/^[.a-zA-Z0-9_-]+ ?:  .*##.*/ \
		{ \
			printf "\033[36m%-55s\033[0m", $$1; \
			c=""; \
			for(i=4;i<=NF;i++) \
			{ \
				c=c $$i" "; \
			} \
			printf c"\n" \
		} \
		END { print "==END==" }' \
		$(MAKEFILE_LIST)

.PHONY: check-IP
check-IP :  ## Check container IPs
	@printf "\033[36m%-30s\033[0m" "Container Names"; printf "%-30s" "Networks"; printf "%-20s\n" "IP"
	@docker container ls --format={{.Names}} | \
		xargs -I{} bash -c '\
			printf "\033[36m%-30s\033[0m" "{}"; \
			docker inspect --format={{.NetworkSettings.Networks}} {} | \
				xargs -I{1} printf "%-30s" "{1}" ; \
			docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" {} | \
				xargs -I{2} printf "%-20s\n" "{2}" '
.PHONY: check-RestartPolicy
check-RestartPolicy :  ## check running container's restart option
	@printf "\033[36m%-30s\033[0m" "Container Names"; printf "%-20s\n" "RestartPolicy"
	@docker container ls --format={{.Names}} | \
		xargs -I{} bash -c '\
			printf "\033[36m%-30s\033[0m" "{}"; \
			docker inspect --format="{{json .HostConfig.RestartPolicy.Name}}" {} | \
				xargs -I{2} printf "%-20s\n" "{2}" '
.PHONY: change-RestartPolicy-always
change-RestartPolicy-always :  ## change all running container's restart options to "always"
	@docker container ls --format={{.Names}} | xargs -I{} docker update --restart=always {}

.PHONY : error
error :  ## errors処理を外部に記述することで好きなエラーメッセージをprintfで記述可能.
	$(error "${ERROR_MESSAGE}")
