.POSIX:

##################
# Additional Tasks
##################

.PHONY: help
help: ## show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | \
	sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: clean
clean: ## cleans remnants of the build process
	echo "TODO: configure clean-prod"
	#. ./scripts/clean.sh dev

.PHONY: inspect
inspect: ## runs psql inside an active local container to allow database inspection and queries
	docker exec -it -u postgres feedreader-db psql

##############
# UAT Workflow
##############

.PHONY: clean-uat
clean-uat: clean ## cleans remnants of the build process on the UAT machine
	. ./scripts/clean.sh uat

.PHONY: build-uat
build-uat: clean-uat ## builds a remote UAT Docker image
	. ./scripts/build.sh uat

.PHONY: deploy-uat
deploy-uat: ## deploys a remote UAT environment
	. ./scripts/deploy.sh uat

.PHONY: stop-uat
stop-uat: ## stops a remote UAT environment
	. ./scripts/stop.sh uat

#####################
# Deployment Workflow
#####################

.PHONY: clean-prod
clean-prod: clean ## cleans remnants of the build process on the production machine
	. ./scripts/clean.sh prod

.PHONY: build
build: clean-prod ## builds a remote production Docker image
	. ./scripts/build.sh prod

.PHONY: stop
stop: ## stops the remote production service
	. ./scripts/stop.sh prod

.PHONY: deploy
deploy: ## deploys the remote production Docker image
	. ./scripts/deploy.sh prod

.PHONY: redeploy
redeploy: stop build deploy ## stops, builds, and deploys a new production Docker image
