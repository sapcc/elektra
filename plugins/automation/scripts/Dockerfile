FROM ruby:2.6-alpine

WORKDIR /omnitruck
RUN apk add --no-cache git build-base linux-headers --virtual .builddeps \
      && git clone https://github.com/chef/omnitruck.git . \
      && bundle install --without "test security" \
      && runDeps="$( \
		      scanelf --needed --nobanner --recursive /usr/local \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
          )" \
      && apk add --virtual .rundeps $runDeps git \
      && apk del .builddeps
ADD generate .
CMD ["./generate"]

