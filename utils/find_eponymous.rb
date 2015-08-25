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
    "Find eponymous links by inspecting template inclusion."

  on :t=, :templates, "File with template inclusion (CSV)", required: true
  on :o=, :output, "File with ids Wikipedia categories including the template", required: true
  on :c=, :config, "YAML file with language specific config", required: true
end

begin
  options.parse
rescue Slop::MissingOptionError => ex
  puts ex
  puts options
  exit
end

eponymy = YAML.load_file(options[:config])[:eponymy]
matcher = /#{eponymy}/i
pages = Set.new
CSV.open(options[:templates],"r:utf-8") do |input|
  input.with_progress do |id,*templates|
    if templates.any?{|t| t =~ matcher}
      pages << id
    end
  end
end

CSV.open(options[:input],"w") do |output|
  pages.each.with_progress do |id|
    output << [id]
  end
end
