SHELL       := /bin/sh
REGISTRY    := localhost
NAMESPACE   := monsoon
NAME        := dashboard
IMAGE       := $(REGISTRY)/$(NAMESPACE)/$(NAME)

STAGE       ?= build
DATE        := $(shell date +%Y%m%d)
VERSION     := $(STAGE).$(DATE)$(if $(POINT_VERSION),.$(POINT_VERSION))

BUILD_IMAGE := localhost/monsoon/build:1.0.2

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
	@echo "  * promote - tags $(VERSION) as TARGET_VERSION"
	@echo "  * freeze  - tags SOURCE_VERSION as $(VERSION)"

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
	@if [ -z "$$TARGET_VERSION" ]; then \
		echo "You need to set TARGET_VERSION to use the promote target"; \
		exit 1; \
	fi
	$(DOCKER) tag -f $(IMAGE):$(VERSION) $(IMAGE):${TARGET_VERSION}
	$(DOCKER) push $(IMAGE):$(TARGET_VERSION)

.PHONY: freeze 
freeze:
	@if [ -z "$$SOURCE_VERSION" ]; then \
		echo "You need to set SOURCE_VERSION to use the freeze target"; \
		exit 1; \
	fi
	$(DOCKER) tag -f $(IMAGE):$(SOURCE_VERSION) $(IMAGE):${VERSION}
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
	@$(if $(SOURCE_VERSION), echo "  SOURCE_VERSION = $(SOURCE_VERSION)")
	@$(if $(TARGET_VERSION), echo "  TARGET_VERSION = $(TARGET_VERSION)")
	@echo "  BUILD_IMAGE    = $(BUILD_IMAGE)"
	@echo "------------------------------------------------------------------------------------"
