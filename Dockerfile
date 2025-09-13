FROM ruby:3.1

RUN bundle config --global frozen 1

WORKDIR /usr/src/app

# prepare to install ruby packages into container
COPY Gemfile Gemfile.lock ./

RUN bundle install && git config --global --add safe.directory /usr/src/app

VOLUME /usr/src/app

EXPOSE 4000

CMD ["jekyll", "serve"]
