#!/usr/bin/env ruby

require 'bundler/setup'
require 'cyclopedio/sql'
require 'slop'

options = Slop.new do
  banner "#{$PROGRAM_NAME} -f file.sql\nParse SQL insert files"
  on :f=, :file, "SQL file to parse", required: true
end

begin
  options.parse
rescue Slop::MissingOptionError => ex
  puts ex
  puts options
  exit
end

file = options[:file]

map = Hash.new{|h,e| h[e] = [] }
File.open(file) do |input|
  Cyclopedio::SQL::Reader.new(input).each_tuple do |tuple|
    p tuple
  end
end
map.each do |from,entries|
  puts from
  entries.each{|e| puts "- #{e}" }
end
