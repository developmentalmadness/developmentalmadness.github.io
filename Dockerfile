FROM ruby:2.3

EXPOSE 4567

RUN apt-get update && apt-get install -y --no-install-recommends npm nodejs \
  && gem install middleman  

WORKDIR /home/app
VOLUME /home/app