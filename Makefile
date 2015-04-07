SHELL     = /bin/sh
REGISTRY  = localhost
NAMESPACE = monsoon
NAME      = dashboard
IMAGE     = $(REGISTRY)/$(NAMESPACE)/$(NAME)

.PHONY: 			 all build test tag push postgres clean git-set-mtimes
.INTERMEDIATE: version

all:
	@echo "Available targets:"
	@echo "  * build - build $(IMAGE)"
	@echo "  * test  - test $(IMAGE)"
	@echo "  * push  - tags and pushes $(IMAGE)"

build: git-set-mtimes
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
	rm -rf version
	docker kill $$(docker ps -aq) &> /dev/null || true
	docker rm $$(docker ps -aq) &> /dev/null   || true

version:
	docker run localhost/monsoon/build \
						 /image_daily_version -r $(REGISTRY) \
																	-n $(NAMESPACE) \
																	-i $(NAME) > version

git-set-mtimes: 
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
