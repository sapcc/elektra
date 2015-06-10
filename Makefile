SHELL       := /bin/sh
IMAGE       := localhost/monsoon/monsoon-dashboard
BUILD_IMAGE := localhost/monsoon/docker-build:1.3.0

### Executables
DOCKER := docker

### Versioning
STAGE ?= build

ifeq ($(STAGE),test)
	PARENT_STAGE := build
endif

ifeq ($(STAGE),alpha)
	PARENT_STAGE := test
endif

ifeq ($(STAGE),beta)
	PARENT_STAGE := alpha
endif

ifeq ($(STAGE),stable)
	PARENT_STAGE := beta
endif

DATE           := $(shell date +%Y%m%d)
VERSION        := $(STAGE).$(DATE)$(if $(POINT_VERSION),.$(POINT_VERSION))
TARGET_VERSION := $(STAGE)-approved.$(DATE)$(if $(POINT_VERSION),.$(POINT_VERSION))
ifdef PARENT_STAGE
PARENT_VERSION := $(shell $(DOCKER) run $(BUILD_IMAGE) monsoonctl-version latest -i $(IMAGE) -t $(PARENT_STAGE)-approved)
endif
LATEST_VERSION := $(STAGE).latest

### Variables that are expanded dynamically
postgres = $(shell cat postgres 2> /dev/null)
webapp   = $(shell cat webapp 2> /dev/null)

### Make Idiomatic Targets

.PHONY: help 
help: info
	@echo
	@echo "Available targets:"
	@echo "  * build   - build a docker image"
	@echo "  * test    - runs all test targets for $(IMAGE)"
	@echo "  * promote - tags $(VERSION) as $(TARGET_VERSION)"
ifdef PARENT_VERSION
	@echo "  * lock    - tags $(PARENT_VERSION) as $(VERSION)"
endif

# Return everything into a pristine state. Stops dependant processes and
# deleted intermediate files
.PHONY: clean
clean: 	
	$(DOCKER) kill $(postgres) &> /dev/null || true
	$(DOCKER) rm   $(postgres) &> /dev/null || true
	$(DOCKER) kill $(webapp) &> /dev/null || true
	$(DOCKER) rm   $(webapp) &> /dev/null || true
	$(RM) webapp
	$(RM) postgres
	$(RM) version


### Docker Targets 

.PHONY: version
version: 
	echo $(VERSION) > version

.PHONY: build
build: reset_mtimes version
	$(DOCKER) build -t $(IMAGE):$(VERSION) --rm . 

.PHONY: promote
promote: 
	$(DOCKER) pull $(IMAGE):$(VERSION)
	$(DOCKER) tag -f $(IMAGE):$(VERSION) $(IMAGE):${TARGET_VERSION}
	$(DOCKER) tag -f $(IMAGE):$(VERSION) $(IMAGE):${LATEST_VERSION}
	$(DOCKER) push $(IMAGE):$(TARGET_VERSION)
	$(DOCKER) push $(IMAGE):$(LATEST_VERSION)

.PHONY: lock 
lock:
ifndef PARENT_VERSION
	@echo "Couldn't find a source version to lock."
	@exit 1
endif
	$(DOCKER) pull $(IMAGE):$(PARENT_VERSION)
	$(DOCKER) tag -f $(IMAGE):$(PARENT_VERSION) $(IMAGE):${VERSION}
	$(DOCKER) push $(IMAGE):${VERSION}

.PHONY: push 
push: 
	$(DOCKER) push $(IMAGE):$(VERSION)

.PHONY: pull 
pull:
	$(DOCKER) pull $(IMAGE):$(VERSION)


### Rails Targets 

.PHONY: test 
test: rspec cucumber 

.PHONY: 
migrate-%: postgres
	$(DOCKER) run --rm --link $(postgres):postgres -e RAILS_ENV=$* $(IMAGE):$(VERSION) \
		sudo -E -u app bundle exec rake db:create db:migrate 

.PHONY: rspec 
rspec: migrate-test
	$(DOCKER) run --rm --link $(postgres):postgres $(IMAGE):$(VERSION) bundle exec rspec

.PHONY: cucumber
cucumber: migrate-test
	$(DOCKER) run --rm --link $(postgres):postgres $(IMAGE):$(VERSION) bundle exec cucumber

.PHONY: precompile 
precompile: webapp
	$(DOCKER) exec $(webapp) env RAILS_ENV=production sudo -E -u app bundle exec rake assets:precompile
	$(DOCKER) commit $(webapp) $(IMAGE):$(VERSION)


### Required Containers 

webapp: migrate-production
	$(DOCKER) run --link $(postgres):postgres -d $(IMAGE):$(VERSION) > $@ 
	$(MAKE) wait_for_webapp

# Starts postgres and saves the container id in "postgres"
postgres: 
	$(DOCKER) run -d postgres > $@ 
	$(MAKE) wait_for_postgres


# Waits for the postgres port to become available. Required because of race
# conditions when later processes start fastet than the database. This needs to
# be an extra target because make will not be able to know the container id or
# read the generated file in the same target (or at least I don't know how). 
.PHONY: wait_for_postgres
wait_for_postgres:  
	$(DOCKER) run --rm --link $(postgres):postgres $(BUILD_IMAGE) wait

.PHONY: wait_for_webapp
wait_for_webapp:  
	$(DOCKER) run --rm --link $(webapp):webapp $(BUILD_IMAGE) wait -p 80


### Helper Targets

# Resets the modification times of all files in a git repository to the date of
# the latest commit that changed it. This is required because Docker takes the
# mtime of a file into account when checking for modifications. Git on the other
# hand does not. Without this the cache will be busted by Git and is basically
# useless.
.PHONY: reset_mtimes
reset_mtimes: 
	$(DOCKER) run --rm -v $(shell pwd):/src $(BUILD_IMAGE) reset_mtimes

# Print a banner containing all expanded variables. Great for verifying
# environment variables are being passed correctly, etc.
.PHONY: info
info:
	@echo "------------------------------------------------------------------------------------"
	@echo "  Environment"
	@echo "------------------------------------------------------------------------------------"
	@echo "  STAGE:         ${STAGE}"
ifdef POINT_VERSION
	@echo "  POINT_VERSION: $(POINT_VERSION)"
endif
	@echo
	@echo "------------------------------------------------------------------------------------"
	@echo " Docker " 
	@echo "------------------------------------------------------------------------------------"
	@echo "  Image:       $(IMAGE)"
	@echo "  Build Image: $(BUILD_IMAGE)"
	@echo
	@echo "------------------------------------------------------------------------------------"
	@echo "  Versions"
	@echo "------------------------------------------------------------------------------------"
ifdef PARENT_VERSION
	@echo "  Parent:  $(PARENT_VERSION)"
endif
	@echo "  Current: $(VERSION)"
	@echo "  Target:  $(TARGET_VERSION)"
	@echo
