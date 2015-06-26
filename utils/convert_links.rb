#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler/setup'
require 'cyclopedio/sql'
require 'slop'
require 'csv'

options = Slop.new do
  banner "#{$PROGRAM_NAME} -f file.sql -s by_source.csv -t by_target.csv\nParse SQL article link file."
  on :f=, :input, "SQL file to parse", required: true
  on :s=, :by_source, "CSV output file sorted by link source", required: true
  on :t=, :by_target, "CSV output file sorted by link target", required: true
end

begin
  options.parse
rescue Slop::MissingOptionError => ex
  puts ex
  puts options
  exit
end
begin
  input = File.open(options[:input],"r:utf-8")
  by_source = CSV.open(options[:by_source],"w:utf-8")
  by_target = CSV.open(options[:by_target],"w:utf-8")

  Cyclopedio::SQL::Reader.new(input).each_tuple do |tuple|
    begin
      next unless tuple[:pl_namespace] == '0'
      next unless tuple[:pl_from_namespace] == '0'
      source_id = tuple[:pl_from]
      target_name = tuple[:pl_title].tr("_"," ")
      by_source << [source_id,target_name]
      by_target << [target_name,source_id]
    rescue Interrupt
      puts
      break
    rescue Exception => ex
      puts ex
    end
  end
ensure
  input.close
  by_source.close
  by_target.close
end


puts "Sorting by source"
path = options[:by_source]
`LC_ALL=C sort #{path} -T #{File.dirname(path)} --field-separator=, -k 1n > #{path}.sorted`
puts "Merging"
last_id = nil
targets = []
CSV.open("#{path}.sorted","r:utf-8") do |input|
  CSV.open("#{path}.merged","w") do |output|
    input.with_progress do |source_id,target_name|
      if source_id != last_id
	output << targets unless targets.size <= 1
	targets = [source_id]
      end
      last_id = source_id
      targets << target_name
    end
    output << targets unless targets.size <= 1
  end
end
puts "Clean up by source"
`rm #{path}.sorted`
`mv #{path}.merged #{path}`

puts "Sorting by target"
path = options[:by_target]
`LC_ALL=C sort #{path} -T #{File.dirname(path)} --field-separator=, -k 1 > #{path}.sorted`
puts "Merging"
last_name = nil
sources = []
CSV.open("#{path}.sorted","r:utf-8") do |input|
  CSV.open("#{path}.merged","w") do |output|
    input.with_progress do |target_name,source_id|
      if target_name != last_name
	output << sources unless sources.size <= 1
	sources = [target_name]
      end
      last_name = target_name
      sources << source_id
    end
    output << sources unless sources.size <= 1
  end
end
puts "Clean up by target"
`rm #{path}.sorted`
`mv #{path}.merged #{path}`
