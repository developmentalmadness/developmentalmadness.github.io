FROM ruby:2.4

WORKDIR /usr/src/app
ADD Gemfile* ./
RUN bundle install 

EXPOSE 4567

CMD ["bundle","exec","middleman"]
