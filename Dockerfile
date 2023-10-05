FROM ruby:2.7.2-slim
RUN apt-get update -qq &&\
	apt-get install -y lbzip2 ragel g++ &&\
	rm -rf /var/lib/apt/lists/* /var/cache/apt/*
RUN bundle config --global frozen 1
RUN mkdir /sql
WORKDIR /sql
COPY Gemfile /sql
COPY Gemfile.lock /sql
COPY cyclopedio-sql.gemspec /sql
RUN bundle
COPY . /sql