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

if ARGV.length < 2
  puts "usage: #{$0} <flickr_csv> <flickr_csv_with_im_average_colour>"
  exit
end

FILENAME = ARGV[0]

csv_array = []

CSV.foreach(FILENAME, :headers => true) do |p|
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

  #synth_75sqfilename (the filename of the 75x75 thumbnail)
  #synth_75imaveragecolour (average colour by resizing to 1x1 in imagemagick)
  #synth_75sqisvalid (in case the thumbnail is not a valid jpeg or png), 1 = valid, 0 = invalid (there's only 1 invalid 75x75px thumbnail from all 45000 2019-2020 photos
  p["synth_75sqfilename"] = filename

  magickimp = sprintf("magick convert \"%s\" -resize 1x1 txt:- | ggrep -Po \"#[[:xdigit:]]{6}\"",
    filename.gsub(/\$/, '\$'))
  logger.debug magickimp
  p["synth_75imaveragecolour"] = ""
  stdout, stderr, status = Open3.capture3(magickimp)
  if status.success?
    p["synth_75imaveragecolour"] = stdout.chomp
    p["synth_75sqisvalid"] = 1
  else
    p["synth_75sqisvalid"] = 0
    logger.debug stderr
    logger.debug 'error: could not execute magick convert command'
  end
  logger.debug p.ai
  csv_array.push(p)
end
headers = csv_array[0].keys
FILENAME = sprintf("%s", ARGV[1])
CSV.open(FILENAME, "w", write_headers: true, headers: headers) do |csv_object|
  csv_array.each {|row_array| csv_object << row_array }
end