FROM ruby:latest

WORKDIR /app
COPY . /app

RUN apt update
RUN apt install libsodium23
RUN bundle install

CMD ruby ./main.rb

