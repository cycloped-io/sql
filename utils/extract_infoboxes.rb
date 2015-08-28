#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler/setup'
require 'slop'
require 'csv'
require 'yaml'
require 'set'
require 'progress'

options = Slop.new do
  banner "#{$PROGRAM_NAME} -t templates.csv -o infobox.csv \n" +
    "Extract infobox links from templates."

  on :t=, :templates, "File with template inclusion (CSV)", required: true
  on :o=, :output, "File with ids of Wikipedia categories and their infoboxes", required: true
end

begin
  options.parse
rescue Slop::MissingOptionError => ex
  puts ex
  puts options
  exit
end

`grep -i 'infobox' #{options[:templates]} > #{options[:templates]}.infobox`

CSV.open("#{options[:templates]}.infobox","r:utf-8") do |input|
  CSV.open(options[:output],"w") do |output|
    input.with_progress do |row|
      category_id,*templates = row
      infoboxes = templates.select{|t| t =~ /infobox/i }
      next if infoboxes.empty?
      output << infoboxes.unshift(category_id)
    end
  end
end

`rm #{options[:templates]}.infobox`
