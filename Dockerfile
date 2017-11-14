FROM ruby:latest
RUN mkdir /evertils
WORKDIR /evertils
ADD . /evertils
ADD Gemfile /evertils/Gemfile
ADD Gemfile.lock /evertils/Gemfile.lock
RUN bundle install

ENTRYPOINT [ "evertils" ]