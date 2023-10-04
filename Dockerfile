FROM ruby:2.7.2-slim
RUN bundle config --global frozen 1
RUN mkdir /sql
WORKDIR /sql
COPY Gemfile /sql
COPY Gemfile.lock /sql
COPY cyclopedio-sql.gemspec /sql
RUN bundle
COPY . /sql
RUN bundle exec rake compile
RUN mkdir /data
RUN mkdir /rod