SHELL     = /bin/sh
REGISTRY  = localhost
NAMESPACE = monsoon
NAME      = dashboard
IMAGE     = $(REGISTRY)/$(NAMESPACE)/$(NAME)

.PHONY: 			 all build test tag push postgres clean
.INTERMEDIATE: version

all:
	@echo "Available targets:"
	@echo "  * build - build $(IMAGE)"
	@echo "  * test  - test $(IMAGE)"
	@echo "  * push  - tags and pushes $(IMAGE)"

build:
	docker build -t $(IMAGE) --rm . 

test: docker = docker run --link postgres:postgres 
test: postgres
	$(docker) -e RAILS_ENV=test $(IMAGE) bundle exec rake db:create db:migrate 
	$(docker) $(IMAGE) bundle exec rspec
	$(docker) $(IMAGE) bundle exec cucumber

tag: version
	docker tag -f $(IMAGE) $(IMAGE):$(shell cat version) 

push: tag
	docker push $(IMAGE):$(shell cat version)

postgres: 
	docker kill postgres &> /dev/null  || true
	docker rm -f postgres &> /dev/null || true
	docker run -d --name postgres postgres 
	docker run --link postgres:postgres aanand/wait

clean: 
	rm version
	docker kill $$(docker ps -aq) &> /dev/null || true
	docker rm $$(docker ps -aq) &> /dev/null   || true

version:
	docker run localhost/monsoon/build \
						 /image_daily_version -r $(REGISTRY) \
																	-n $(NAMESPACE) \
																	-i $(NAME) > version
