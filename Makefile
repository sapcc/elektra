IMAGE := sapcc/elektra
ELEKTRA_EXTENSION ?= false

BUILD_ARGS:= --build-arg ELEKTRA_EXTENSION=$(ELEKTRA_EXTENSION)
ifneq ($(http_proxy),)
BUILD_ARGS+= --build-arg http_proxy=$(http_proxy) --build-arg https_proxy=$(https_proxy) --build-arg no_proxy=$(no_proxy)
endif
ifneq ($(NO_CACHE),)
BUILD_ARGS += --no-cache
endif

.PHONY: build CHANGELOG.md

build:
	docker build $(BUILD_ARGS) -t $(IMAGE) .

#
# Creates a changelog file
# Set the environment variable GITHUB_TOKEN=<your github token> or
# Run following command make CHANGELOG.md GITHUB_TOKEN=<your github token>
#
VERSION  ?= $(shell git rev-parse --verify HEAD)
BUILD_ARGS = --build-arg VERSION=$(VERSION)
CHANGELOG.md:
ifndef CHANGELOG_GITHUB_TOKEN
	$(error set CHANGELOG_GITHUB_TOKEN to a personal access token that has repo:read permission)
else
	docker build $(BUILD_ARGS) -t sapcc/elektra-changelog-builder:$(VERSION) --cache-from=sapcc/elektra-changelog-builder:latest ./contrib/elektra-changelog-builder
	docker tag sapcc/elektra-changelog-builder:$(VERSION)  sapcc/elektra-changelog-builder:latest
	docker run --rm -v $(PWD):/host -e HTTPS_PROXY='http://proxy.wdf.sap.corp:8080/' -e GITHUB_TOKEN=$(CHANGELOG_GITHUB_TOKEN) sapcc/elektra-changelog-builder:latest
endif
