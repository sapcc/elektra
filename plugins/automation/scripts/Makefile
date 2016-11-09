IMAGE=hub.global.cloud.sap/monsoon/fetch-chef-versions
ifneq ($(http_proxy),)
BUILD_ARGS:= --build-arg http_proxy=$(http_proxy) --build-arg https_proxy=$(https_proxy) --build-arg no_proxy=$(no_proxy)
endif

generate:
	docker run --rm $(IMAGE) > $(CURDIR)/../config/chef_versions.json
build:
	docker build $(BUILD_ARGS) -t $(IMAGE) .

push:
	docker push $(IMAGE)

