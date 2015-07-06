SHELL       := /bin/sh
REPOSITORY  := localhost/concourse/monsoon-dashboard
TAG         := latest
IMAGE       := $(REPOSITORY):$(TAG)

### Executables
DOCKER = docker 
SCRIPT = $(DOCKER) run --rm $(SCRIPT_OPTS) \
				 localhost/monsoon/docker-build:1.3.0

### Variables that are expanded dynamically
postgres = $(shell cat postgres 2> /dev/null)
webapp   = $(shell cat webapp 2> /dev/null)

.PHONY: test rspec cucumber clean reset_mtimes

image: build precompile
	# --------------------------------------------------------------------------------
	#   image 
	# --------------------------------------------------------------------------------
	echo $(IMAGE) > image

build: SCRIPT_OPTS := -v $(shell pwd):/src
build: 
	# --------------------------------------------------------------------------------
	#   build 
	# --------------------------------------------------------------------------------
	#
	# Reset the modification times of all files in a git repository to the date of
	# the latest commit that changed it. This is required because Docker takes the
	# mtime of a file into account when checking for modifications. Git on the other
	# hand does not. Without this the cache will be busted by Git and is basically
	# useless.
	#
	$(SCRIPT) reset_mtimes
	$(DOCKER) build -t $(IMAGE) --rm . 
	echo $(IMAGE) > build

precompile: webapp
	# --------------------------------------------------------------------------------
	#   precompile 
	# --------------------------------------------------------------------------------
	$(DOCKER) exec $(webapp) \
		env RAILS_ENV=production bundle exec rake assets:precompile
	$(DOCKER) commit $(webapp) $(IMAGE) > precompile


test: rspec cucumber 

rspec: postgres migrate-test
	# --------------------------------------------------------------------------------
	#   rspec 
	# --------------------------------------------------------------------------------
	$(DOCKER) run --rm --link $(postgres):postgres $(IMAGE) \
		bundle exec rspec

CUCUMBER_PROFILE ?= default
CUCUMBER_OPTIONS  =

ifdef CAPYBARA_APP_HOST 
	CUCUMBER_OPTIONS += -e CAPYBARA_APP_HOST=$(CAPYBARA_APP_HOST)
endif

cucumber: postgres migrate-test
	# --------------------------------------------------------------------------------
	#   cucumber 
	# --------------------------------------------------------------------------------
	$(DOCKER) run --rm --link $(postgres):postgres $(CUCUMBER_OPTIONS) $(IMAGE) \
		bundle exec cucumber -p $(CUCUMBER_PROFILE) 


webapp: SCRIPT_OPTS := --link $(webapp):webapp
webapp: migrate-production
	# --------------------------------------------------------------------------------
	#   webapp
	# --------------------------------------------------------------------------------
	$(DOCKER) run --link $(postgres):postgres -d $(IMAGE) > webapp 
	$(SCRIPT) wait -p 80

postgres: SCRIPT_OPTS := --link $(postgres):postgres
postgres: 
	# --------------------------------------------------------------------------------
	#   postgres 
	# --------------------------------------------------------------------------------
	$(DOCKER) run -d postgres > postgres 
	$(SCRIPT) wait

.PHONY: 
migrate-%: postgres 
	# --------------------------------------------------------------------------------
	#   $@ 
	# --------------------------------------------------------------------------------
	$(DOCKER) run --rm --link $(postgres):postgres -e RAILS_ENV=$* $(IMAGE) \
		bundle exec rake db:create db:schema:load db:migrate db:seed

clean: 	
	# --------------------------------------------------------------------------------
	#   clean 
	# --------------------------------------------------------------------------------
	$(DOCKER) rm -f $(postgres) $(webapp) &> /dev/null || true
	$(RM) image build precompile webapp postgres
