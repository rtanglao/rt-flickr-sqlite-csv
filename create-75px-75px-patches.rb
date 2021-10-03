#!/usr/bin/env ruby
require 'json'
require 'rubygems'
require 'awesome_print'
require 'json'
require 'time'
require 'date'
require 'csv'
require 'logger'
require 'open3'

logger = Logger.new(STDERR)
logger.level = Logger::DEBUG

if ARGV.length < 2
  puts "usage: #{$0} [max75-maxy75-filename] [number_of_75px by 75px patches]"
  exit
end

FILENAME = ARGV[0]
number_of_patches = ARGV[1].to_i
file_array = []
CSV.foreach(FILENAME, :headers => true) do |row|
  logger.debug row
  file_array.push(
  	[
  		row["file"],
  		row["max75x"].to_i,
  		row["max75y"].to_i
  	])
end
length_of_file_array = file_array.length
number_of_patches.times do |i|
  file_index = rand(length_of_file_array)
  file = file_array[file_index][0]
  max_x_index = file_array[file_index][1] + 1
  max_y_index = file_array[file_index][2] + 1
  x_offset = rand(max_x_index) * 75
  y_offset = rand(max_y_index) * 75
  filebasename = File.basename(file, "*.png")
  filename = sprintf("%s-%d-%d.jpg", filebasename, x_offset, y_offset)
  offset_str = sprintf("75x75+%d+%d", x_offset, y_offset)
  magickimp = "magick #{file} -crop #{offset_str} +repage #{filename}"

  Open3.popen2e(magickimp) do |stdin, stdout_stderr, wait_thread|
  	Thread.new do
  		stdout_stderr.each {|l| puts l }
  	end

  #stdin.puts "DROP DATABASE IF EXISTS #{mysqllocal['db']};"
  #stdin.puts "CREATE DATABASE #{mysqllocal['db']};"
  #stdin.puts "USE #{mysqllocal['db']};"
  stdin.close

  wait_thread.value
end
end

