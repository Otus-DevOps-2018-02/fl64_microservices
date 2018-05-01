FROM alpine:3.7
MAINTAINER Pavel Tishkov <tishkov.pavel@gmail.com>

ENV APP_HOME /app

RUN mkdir "$APP_HOME"

WORKDIR $APP_HOME
COPY Gemfile* $APP_HOME/
COPY . $APP_HOME

RUN apk update \
    && apk add --no-cache build-base ruby ruby-bundler ruby-dev ruby-json \
    && gem install bundler --no-ri --no-rdoc \
    && gem cleanup \
    && bundle install --without development test \
    && apk del build-base ruby-dev \
    && rm -rf /usr/lib/ruby/gems/*/cache/* /var/cache/apk/* /tmp/* /var/tmp/*

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]
