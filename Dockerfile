FROM ruby:latest

ENV GEM_HOME="/usr/local/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

WORKDIR /app
COPY . /app

RUN apt update
RUN apt install libsodium23
RUN bundler install

CMD [ "ruby", "./src/main.rb" ]
