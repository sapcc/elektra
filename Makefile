SHELL       := /bin/sh
REPOSITORY  := localhost/monsoon/monsoon-dashboard
TAG         ?= latest
IMAGE       := $(REPOSITORY):$(TAG)

### Executables
DOCKER      = docker
WAIT        = $(DOCKER) run --rm --link $(WAIT_ID):wait $(WAIT_OPTS) localhost/monsoon-docker/wait || ($(DOCKER) logs $(WAIT_ID) && false)

### Variables that are expanded dynamically
postgres = $(shell cat postgres 2> /dev/null)
webapp   = $(shell cat webapp 2> /dev/null)

# ----------------------------------------------------------------------------------
#   image 
# ----------------------------------------------------------------------------------
image: build
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
build: 
	$(DOCKER) pull $(REPOSITORY):latest || true
	$(DOCKER) build -t $(IMAGE) --rm . 
	echo $(IMAGE) > build

# ----------------------------------------------------------------------------------
#   test 
# ----------------------------------------------------------------------------------
#
# Runs all unit tests suits.
#
.PHONY: 
test: rspec

.PHONY: 
beta: cucumber

#target for testing pull requests from the ci pipeline
.PHONY:
pr: build rspec

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
	env | grep '^CCTEST' > cc_env.txt
	$(DOCKER) run --rm  --env-file=cc_env.txt --link $(postgres):postgres $(CUCUMBER_OPTIONS) $(IMAGE) \
		bundle exec cucumber -p $(CUCUMBER_PROFILE)
	rm -f cc_env.txt

# ----------------------------------------------------------------------------------
#   webapp 
# ----------------------------------------------------------------------------------
#
# Start the application and its required containers. Waits until it is
# listening on port 80
#
webapp: WAIT_ID = $$(cat webapp)
webapp: WAIT_OPTS = -e PORT=80
webapp: migrate-production
	$(DOCKER) run --link $(postgres):postgres -d $(IMAGE) > webapp 
	$(WAIT)

# ----------------------------------------------------------------------------------
#   postgres 
# ----------------------------------------------------------------------------------
#
# Start postgres database and wait for it to become available. 
#
postgres: WAIT_ID = $$(cat postgres)
postgres: 
	$(DOCKER) run -d localhost/monsoon/postgres:9.5-alpine > postgres 
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
