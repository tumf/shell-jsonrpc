FROM ruby:2.7-alpine
RUN apk add --update --no-cache build-base libstdc++

COPY Gemfile /
COPY app.rb /

RUN bundle install

EXPOSE 8999
CMD ruby /app.rb
