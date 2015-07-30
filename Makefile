SHELL       := /bin/sh
REPOSITORY  := localhost/monsoon/monsoon-dashboard
TAG         ?= latest
IMAGE       := $(REPOSITORY):$(TAG)

### Executables
DOCKER      = docker
BUILD_IMAGE = localhost/monsoon/docker-build:1.5.0 
WAIT        = $(DOCKER) run --rm --link $(WAIT_ID):wait $(BUILD_IMAGE) wait
MTIMES      = $(DOCKER) run --rm $(MTIMES_OPTS)         $(BUILD_IMAGE) reset_mtimes

### Variables that are expanded dynamically
postgres = $(shell cat postgres 2> /dev/null)
webapp   = $(shell cat webapp 2> /dev/null)

# ----------------------------------------------------------------------------------
#   image 
# ----------------------------------------------------------------------------------
image: build precompile
	echo $(IMAGE) > image

# ----------------------------------------------------------------------------------
#   build 
# ----------------------------------------------------------------------------------
#
# Build and tags an image from a Dockerfile.
#
# We need to reset the modification times of all files in a git repository to the 
# date of the latest commit that changed it. This is required because Docker takes 
# the mtime of a file into account when checking for modifications. Git on the other
# hand does not. Without this the cache will be busted by Git and is basically
# useless.
#
build: MTIMES_OPTS = -v $(shell pwd):/src
build: 
	#$(MTIMES)
	$(DOCKER) pull $(REPOSITORY):latest || true
	$(DOCKER) build -t $(IMAGE) --rm . 
	echo $(IMAGE) > build

# ----------------------------------------------------------------------------------
#   precompile 
# ----------------------------------------------------------------------------------
#
# Precompiles the assets for this application. 
#
# In order to do so we first need to start the application container. Then we
# execute the precompile rake task.  And finally we commit and tag the
# resulting container, which now contains all precompiled assets.
#
precompile: webapp
	$(DOCKER) exec $(webapp) \
		env RAILS_ENV=production bundle exec rake assets:precompile
	$(DOCKER) commit $(webapp) $(IMAGE) > precompile

# ----------------------------------------------------------------------------------
#   test 
# ----------------------------------------------------------------------------------
#
# Runs all unit tests suits.
#
.PHONY: 
test: rspec cucumber 

.PHONY: 
alpha: CAPYBARA_APP_HOST=https://localhost
alpha: CUCUMBER_PROFILE=integration
alpha: cucumber 
	
.PHONY: 
beta: CAPYBARA_APP_HOST=https://localhost
beta: CUCUMBER_PROFILE=e2e
beta: cucumber

# ----------------------------------------------------------------------------------
#   rspec 
# ----------------------------------------------------------------------------------
#
# Runs the rspec test suit. Requires the postgres db to be started and
# prepared. 
#
.PHONY: 
rspec: postgres migrate-test
	$(DOCKER) run --rm --link $(postgres):postgres $(IMAGE) \
		bundle exec rspec

# ----------------------------------------------------------------------------------
#   cucumber 
# ----------------------------------------------------------------------------------
#
# Runs the cucumber test suit. Requires the postgres db to be started and
# prepared. 
#
# It is possible to overwrite the profile that gets executed using the environment 
# variable CUCUMBER_PROFILE. See config/cucumber.yml for available profiles. 
#
# Using CAPYBARA_APP_HOST it is possible to pass in a remote host that the
# tests are being executed against.
#
CUCUMBER_PROFILE ?= default
CUCUMBER_OPTIONS  =

ifdef APP_HOST 
CUCUMBER_OPTIONS += -e CAPYBARA_APP_HOST=$(APP_HOST)
endif

.PHONY: 
cucumber: postgres migrate-test
	$(DOCKER) run --rm  --link $(postgres):postgres $(CUCUMBER_OPTIONS) $(IMAGE) \
		 bundle exec cucumber -p $(CUCUMBER_PROFILE) 

# ----------------------------------------------------------------------------------
#   webapp 
# ----------------------------------------------------------------------------------
#
# Start the application and its required containers. Waits until it is
# listening on port 80
#
webapp: WAIT_ID = $$(cat webapp)
webapp: migrate-production
	$(DOCKER) run --link $(postgres):postgres -d $(IMAGE) > webapp 
	$(WAIT) -p 80

# ----------------------------------------------------------------------------------
#   postgres 
# ----------------------------------------------------------------------------------
#
# Start postgres database and wait for it to become available. 
#
postgres: WAIT_ID = $$(cat postgres)
postgres: 
	$(DOCKER) run -d postgres > postgres 
	$(WAIT)

# ----------------------------------------------------------------------------------
#   migrate-%
# ----------------------------------------------------------------------------------
#
# Prepare the database by running the db tasks for the given environment. 
#
.PHONY: 
migrate-%: postgres 
	$(DOCKER) run --rm --link $(postgres):postgres -e RAILS_ENV=$* $(IMAGE) \
		bundle exec rake db:create db:schema:load db:migrate db:seed

# ----------------------------------------------------------------------------------
#   clean 
# ----------------------------------------------------------------------------------
#
# Kill and remove all containers. Remove intermediate files. 
#
.PHONY: 
clean: 	
	$(DOCKER) rm -f $(postgres) $(webapp) &> /dev/null || true
	$(RM) image build precompile webapp postgres
