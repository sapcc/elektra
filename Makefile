SHELL          := /bin/sh
REGISTRY       := localhost
NAMESPACE      := monsoon
NAME           := dashboard
IMAGE          := $(REGISTRY)/$(NAMESPACE)/$(NAME)

STAGE          ?= build
DATE           := $(shell date +%Y%m%d)
VERSION        := $(STAGE).$(DATE)$(if $(POINT_VERSION),.$(POINT_VERSION))
TARGET_VERSION ?= $(STAGE).latest
SOURCE_VERSION ?= build.latest

BUILD_IMAGE    := localhost/monsoon/build:1.0.2

# Executables
DOCKER      := docker

# Variables that are expanded dynamically
postgres    = $(shell cat postgres 2> /dev/null)

# ----------------------------------------------------------------------------------
# Make Idiomatic Targets
# ----------------------------------------------------------------------------------

# This is the default target
.PHONY: info
help: info
	@echo
	@echo "Available targets:"
	@echo "  * build   - builds $(IMAGE):$(VERSION)"
	@echo "  * test    - runs all test targets for $(IMAGE)"
	@echo "  * promote - promotes $(IMAGE):$(VERSION) to $(IMAGE):$(PROMOTION)"

# Return everything into a pristine state. Stops dependant processes and
# deleted intermediate files
.PHONY: clean
clean: 	
	$(DOCKER) kill $(postgres) &> /dev/null || true
	$(DOCKER) rm   $(postgres) &> /dev/null || true
	$(RM) postgres
	$(RM) version

# ----------------------------------------------------------------------------------
# Docker Targets 
# ----------------------------------------------------------------------------------

.PHONY: build
build: reset_mtimes
	$(DOCKER) build -t $(IMAGE):$(VERSION) --rm . 

.PHONY: promote
promote: 
	$(DOCKER) tag -f $(IMAGE):$(VERSION) $(IMAGE):${PROMOTION}
	$(DOCKER) push $(IMAGE):$(PROMOTION)

.PHONY: freeze 
freeze:
	$(DOCKER) tag -f $(IMAGE):$(PARENT) $(IMAGE):${VERSION}
	$(DOCKER) push $(IMAGE):${VERSION}

.PHONY: push 
push: 
	$(DOCKER) push $(IMAGE):$(VERSION)

.PHONY: pull 
pull:
	$(DOCKER) pull $(IMAGE):$(VERSION)

# ----------------------------------------------------------------------------------
# Rails Targets 
# ----------------------------------------------------------------------------------

.PHONY: test 
test: migrate rspec cucumber 

.PHONY: migrate
migrate: postgres 
	$(DOCKER) run --link $(postgres):postgres -e RAILS_ENV=test $(IMAGE):$(VERSION) \
		bundle exec rake db:create db:migrate 

.PHONY: rspec 
rspec: migrate
	$(DOCKER) run --link $(postgres):postgres $(IMAGE):$(VERSION) bundle exec rspec

.PHONY: cucumber
cucumber: migrate
	$(DOCKER) run --link $(postgres):postgres $(IMAGE):$(VERSION) bundle exec cucumber

# ----------------------------------------------------------------------------------
# Required Containers 
# ----------------------------------------------------------------------------------

# Starts postgres and saves the container id in "postgres"
postgres: 
	$(DOCKER) run -d postgres > $@ 
	$(MAKE) wait_for_postgres

# Waits for the postgres port to become available. Required because of race
# conditions when later processes start fastet than the database. This needs to
# be an extra target because make will not be able to know the container id or
# read the generated file in the same target (or at least I don't know how). 
.PHONY: wait_for_postgres
wait_for_postgres: postgres
	$(DOCKER) run --link $(postgres):postgres $(BUILD_IMAGE) /wait

# ----------------------------------------------------------------------------------
# Helper Targets
# ----------------------------------------------------------------------------------

# Creates an incrementing daily version by querying the given image from the
# registry. e.g. v20150401, v20150401.1, v20150401.2, ...
.INTERMEDIATE: version
version: 
	$(DOCKER) run $(BUILD_IMAGE) /image_daily_version \
		-r $(REGISTRY) -n $(NAMESPACE) -i $(NAME) > $@

# Resets the modification times of all files in a git repository to the date of
# the latest commit that changed it. This is required because Docker takes the
# mtime of a file into account when checking for modifications. Git on the other
# hand does not. Without this the cache will be busted by Git and is basically
# useless.
.PHONY: reset_mtimes
reset_mtimes: 
	$(DOCKER) run -v $(shell pwd):/git $(BUILD_IMAGE) /reset_mtimes

# Print a banner containing all expanded variables. Great for verifying
# environment variables are being passed correctly, etc.
.PHONY: info
info:
	@echo "------------------------------------------------------------------------------------"
	@echo "  Environment"
	@echo "------------------------------------------------------------------------------------"
	@echo "  IMAGE          = $(IMAGE)"
	@echo "  VERSION        = $(VERSION)"
	@echo
	@echo "  SOURCE_VERSION = $(SOURCE_VERSION)"
	@echo "  TARGET_VERSION = $(TARGET_VERSION)"
	@echo
	@echo "  BUILD_IMAGE    = $(BUILD_IMAGE)"
	@echo "------------------------------------------------------------------------------------"
