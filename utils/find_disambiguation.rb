#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler/setup'
require 'slop'
require 'csv'
require 'yaml'
require 'set'
require 'progress'

options = Slop.new do
  banner "#{$PROGRAM_NAME} -f file.sql -o output.csv [-c config.en.yml]\n" +
    "Parse SQL page file."
  on :f=, :input, "File with pages (CSV)", required: true
  on :t=, :templates, "File with template inclusion (CSV)", required: true
  on :c=, :config, "YAML file with language specific config", required: true
end

begin
  options.parse
rescue Slop::MissingOptionError => ex
  puts ex
  puts options
  exit
end

disambiguation = YAML.load_file(options[:config])[:disambiguation]
matcher = /#{disambiguation}/
pages = Set.new
CSV.open(options[:templates]) do |input|
  input.with_progress do |id,*templates|
    if templates.any?{|t| t =~ matcher}
      pages << id
    end
  end
end

CSV.open(options[:input]+".new","w") do |output|
  CSV.open(options[:input]) do |input|
    input.with_progress do |id,title,type,zero,length|
      if pages.include?(id) and type == '0'
        type = '3'
      end
      output << [id,title,type,zero,length]
    end
  end
end

File.delete(options[:input])
File.rename(options[:input]+".new",options[:input])
