SHELL := /bin/bash
.DEFAULT_GOAL := help

export

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
