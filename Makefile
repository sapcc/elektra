SHELL     := /bin/sh
REGISTRY  := localhost
NAMESPACE := monsoon
NAME      := dashboard
IMAGE     := $(REGISTRY)/$(NAMESPACE)/$(NAME)

DOCKER    := docker

postgres   = $(shell cat postgres 2> /dev/null)
version    = $(shell cat version  2> /dev/null)

.PHONY: 			 all build test migrate rspec cucumber tag push clean \
							 wait_for_postgres reset_mtimes
.INTERMEDIATE: version

all:
	@echo "Available targets:"
	@echo "  * build - build $(IMAGE)"
	@echo "  * test  - test $(IMAGE)"
	@echo "  * push  - tags and pushes $(IMAGE)"

build: reset_mtimes
	$(DOCKER) build -t $(IMAGE) --rm . 

test: migrate rspec cucumber 

migrate: postgres 
	$(DOCKER) run --link $(postgres):postgres -e RAILS_ENV=test $(IMAGE) \
								bundle exec rake db:create db:migrate 

rspec: migrate
	$(DOCKER) run --link $(postgres):postgres $(IMAGE) bundle exec rspec

cucumber: migrate
	$(DOCKER) run --link $(postgres):postgres $(IMAGE) bundle exec cucumber

tag: version
	$(DOCKER) tag -f $(IMAGE) $(IMAGE):$(version) 

push: tag
	$(DOCKER) push $(IMAGE):$(version)

pull:
	$(DOCKER) pull $(IMAGE)

clean: 	
	$(DOCKER) kill $(postgres) &> /dev/null || true
	$(DOCKER) rm   $(postgres) &> /dev/null || true
	$(RM) postgres
	$(RM) version

postgres: 
	$(DOCKER) run -d postgres > postgres 

wait_for_postgres: postgres
	$(DOCKER) run --link $(postgres):postgres aanand/wait

version:
	$(DOCKER) run localhost/monsoon/build \
								/image_daily_version -r $(REGISTRY) \
																		 -n $(NAMESPACE) \
																		 -i $(NAME) > version

reset_mtimes: 
	@echo "Reseting mtimes"
	@find . -exec touch -t 201401010000 {} \; 
	@IFS=$$'\n'; \
	files=( $$({ git ls-files | xargs -n1 dirname | sort -u && git ls-files; } | sort -r) ); \
	unset IFS; \
	for x in $${files[@]}; do \
		stamp=$$(git log -1 --format=%ci -- "$${x}"); \
		echo "$${stamp} $${x}"; \
		touch -t $$(date -d "$${stamp}" +%y%m%d%H%M.%S) "$${x}"; \
	done
