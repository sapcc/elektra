SHELL     := /bin/sh
REGISTRY  := localhost
NAMESPACE := monsoon
NAME      := dashboard
IMAGE     := $(REGISTRY)/$(NAMESPACE)/$(NAME)

# Executables
DOCKER    := docker

# Variables that are expanded dynamically
postgres   = $(shell cat postgres 2> /dev/null)
version    = $(shell cat version  2> /dev/null)

.PHONY: all clean \
			  build tag push pull \
				test migrate rspec cucumber \
				wait_for_postgres \
				reset_mtimes

.INTERMEDIATE: version

# ----------------------------------------------------------------------------------
# Make Idiomatic Targets
# ----------------------------------------------------------------------------------

# This is the default target
all:
	@echo "Available targets:"
	@echo "  * build - build $(IMAGE)"
	@echo "  * test  - test $(IMAGE)"
	@echo "  * push  - tags and pushes $(IMAGE)"

# Return everything into a pristine state. Stops dependant processes and
# deleted intermediate files
clean: 	
	$(DOCKER) kill $(postgres) &> /dev/null || true
	$(DOCKER) rm   $(postgres) &> /dev/null || true
	$(RM) postgres
	$(RM) version

# ----------------------------------------------------------------------------------
# Docker Targets 
# ----------------------------------------------------------------------------------

build: reset_mtimes
	$(DOCKER) build -t $(IMAGE) --rm . 

tag: version
	$(DOCKER) tag -f $(IMAGE) $(IMAGE):$(version) 

push: tag
	$(DOCKER) push $(IMAGE):$(version)

pull:
	$(DOCKER) pull $(IMAGE)

# ----------------------------------------------------------------------------------
# Rails Targets 
# ----------------------------------------------------------------------------------

test: migrate rspec cucumber 

migrate: postgres 
	$(DOCKER) run --link $(postgres):postgres \
								-e RAILS_ENV=test \
								$(IMAGE) \
								bundle exec rake db:create db:migrate 

rspec: migrate
	$(DOCKER) run --link $(postgres):postgres \
								$(IMAGE) \
								bundle exec rspec

cucumber: migrate
	$(DOCKER) run --link $(postgres):postgres \
								$(IMAGE) \
								bundle exec cucumber

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
wait_for_postgres: postgres
	$(DOCKER) run --link $(postgres):postgres \
								localhost/monsoon/build \
								/wait

# ----------------------------------------------------------------------------------
# Helper Targets
# ----------------------------------------------------------------------------------

# Creates an incrementing daily version by querying the given image from the
# registry. e.g. v20150401, v20150401.1, v20150401.2, ...
version:
	$(DOCKER) run localhost/monsoon/build \
								/image_daily_version -r $(REGISTRY) \
																		 -n $(NAMESPACE) \
																		 -i $(NAME) > $@

# Resets the modification times of all files in a git repository to the date of
# the latest commit that changed it. This is required because Docker takes the
# mtime of a file into account when checking for modifications. Git on the other
# hand does not. Without this the cache will be busted by Git and is basically
# useless.
reset_mtimes: 
	$(DOCKER) run -v $(shell pwd):/git \
								localhost/monsoon/build \
								/reset_mtimes
