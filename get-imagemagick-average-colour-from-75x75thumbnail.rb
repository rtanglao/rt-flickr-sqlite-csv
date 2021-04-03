#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'json'
require 'time'
require 'date'
require 'csv'
require 'logger'
require 'open3'

logger = Logger.new(STDERR)
logger.level = Logger::DEBUG

if ARGV.length < 1
  puts "usage: #{$0} <flickr_csv>"
  exit
end

FILENAME = ARGV[0]

CSV.foreach(FILENAME, :headers => true) do |p|
  logger.debug p
  id = p["id"]
  title = p["title"].gsub("/", "")
  title = title.gsub(" ", "_")
  title = title.gsub(/["|'|!]/,"")
  url = p["url_sq"]
  if url.nil?
    $stderr.printf("MISSING 75x75 Thumb: photo id:%d, title:%s IS NIL\n", id, title)
    break
  end
  title = title[0..63] if title.length > 64
  datetaken = Time.parse(p["datetaken"])
  filename = sprintf("%4.4d-%2.2d-%2.2d-%2.2d-%2.2d-%2.2d-%d-%s.jpg", 
    datetaken.year, datetaken.month, datetaken.day, datetaken.hour,
    datetaken.min, datetaken.sec, id, title)
  $stderr.printf("photo:%d, title:%s url:%s filename:%s\n", id, title, url, filename)
  magickimp = sprintf("magick convert \"%s\" -resize 1x1 txt:- | ggrep -Po \"#[[:xdigit:]]{6}\"",
    filename.gsub(/\$/, '\$'))
  logger.debug magickimp
  stdout, stderr, status = Open3.capture3(magickimp)
  if status.success?
    puts stdout
  else
    puts("")
    logger.debug stderr
    logger.debug 'error: could not execute magick convert command'
  end
end

