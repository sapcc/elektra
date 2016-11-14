IMAGE := sapcc/elektra

ifneq ($(http_proxy),)
BUILD_ARGS:= --build-arg http_proxy=$(http_proxy) --build-arg https_proxy=$(https_proxy) --build-arg no_proxy=$(no_proxy)
endif
ifneq ($(NO_CACHE),)
BUILD_ARGS += --no-cache
endif

build:
	docker build $(BUILD_ARGS) -t $(IMAGE) .
