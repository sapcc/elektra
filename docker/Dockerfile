# Note: for local build and to prevent rate limit from docker use keppel.eu-de-1.cloud.sap/ccloud-dockerhub-mirror/library/
FROM keppel.eu-de-1.cloud.sap/ccloud-dockerhub-mirror/library/ruby:2.7-alpine3.11 AS elektra

LABEL source_repository="https://github.com/sapcc/elektra"

RUN apk --no-cache add git curl tzdata nodejs postgresql-client yarn shared-mime-info

# Install gems with native extensions before running bundle install
# This avoids recompiling them everytime the Gemfile.lock changes.
# The versions need to be kept in sync with the Gemfile.lock
RUN apk --no-cache add build-base postgresql-dev --virtual .builddeps \
      && gem install bundler:2.3.9 \
      && gem install byebug -v 9.0.6 \
      && gem install ffi -v 1.9.25 \
      && gem install json -v 1.8.6 \
      && gem install nio4r -v 2.5.8 \
      && gem install nokogiri -v 1.12.5 \
      && gem install pg -v 1.3.4 \
      && gem install puma -v 4.3.12  \
      && gem install redcarpet -v 3.5.1 \
      && gem install unf -v 0.2.0.beta2 \
      && gem install websocket-driver -v 0.7.2 \
      && gem install bindex -v 0.6.0 \
      && gem install sassc -v 2.2.1 \
      && runDeps="$( \
      scanelf --needed --nobanner --recursive /usr/local \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u \
      | xargs -r apk info --installed \
      | sort -u \
      )" \
      && apk add --virtual .rundeps $runDeps \
      && apk del .builddeps \
      && gem sources -c \
      && rm -f /usr/local/bundle/cache/*

RUN curl -L -o /usr/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 && \
      chmod +x /usr/bin/dumb-init && \
      dumb-init -V

WORKDIR /home/app/webapp
ENV RAILS_ENV=production

ARG MONSOON_RAILS_SECRET_TOKEN
ENV MONSOON_RAILS_SECRET_TOKEN=$MONSOON_RAILS_SECRET_TOKEN
ARG MONSOON_LOB_LIST
ENV MONSOON_LOB_LIST=$MONSOON_LOB_LIST
ARG MONSOON_NEW_PROJECT_DL
ENV MONSOON_NEW_PROJECT_DL=$MONSOON_NEW_PROJECT_DL

# add Gemfile and Gemfile.lock to /home/app/webapp/
ADD Gemfile Gemfile.lock ./

# add package.json yarn.lock to /home/app/webapp
ADD package.json yarn.lock ./

# copy all gemspec files from plugins folder into /home/app/webapp/tmp/plugins/
ADD plugins/*/*.gemspec tmp/plugins/

# copy organize_plugins_gemspecs script (see comments in script/organize_plugins_gemspecs) and execute it
ADD script/organize_plugins_gemspecs script/
RUN script/organize_plugins_gemspecs

# install gems, copy app and run rake tasks
RUN apk --no-cache add build-base
RUN bundle config set --local without 'development integration_tests'
RUN bundle install 

# add elektra sources into image
ADD . /home/app/webapp

#ENV NODE_ENV=production
# install latest possible node version
#RUN apk add --no-cache nodejs-current 
# yarn task is called within "assets:precompile" -> /workspace/elektra/vendor/bundle/ruby/2.5.0/gems/railties-5.2.6/lib/rails/tasks/yarn.rake
#RUN yarn install --no-progress

# We use dummy master.key to workaround the fact that
# assets:precompile needs them but we don't want the real master.key to be built
# into the container. The MONSOON_RAILS_SECRET_TOKEN should be injected as env var when starting the
# container.
# https://github.com/rails/rails/issues/32947

ENV MONSOON_RAILS_SECRET_TOKEN=dummy_monsoon_rails_build_secret_token_for_assets_precompiling_change_it_in_production
RUN bin/rails assets:precompile && rm -rf tmp/cache/assets

ENTRYPOINT ["dumb-init", "-c", "--" ]
CMD ["script/start.sh"]

FROM elektra AS tests
RUN apk add --no-cache postgresql bash
ENV RAILS_ENV=test
RUN LISTENTO=127.0.0.1 su postgres -c 'script/pg_tmp.sh -p 5432 -w 300 -d /tmp/pg start' \
      && rake db:create db:migrate \
      && bundle exec rspec \
      && su postgres -c 'script/pg_tmp.sh -d /tmp/pg stop'
      # && yarn test # we cannot run the react tests here because there are a lot of devDependencies that are not installed

FROM elektra