FROM ruby:2.4.3-alpine

RUN mkdir -p /app
WORKDIR /app
RUN apk add --update \
    make \
    g++
COPY Gemfile Gemfile.lock /app/
RUN bundle install
COPY . /app/
CMD ["bundle", "exec", "ruby", "bot/runner.rb"]
