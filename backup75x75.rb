#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'json'
require 'curb'
require 'pp'
require 'time'
require 'date'
require 'open-uri'
require 'csv'

if ARGV.length < 1
  puts "usage: #{$0} <url of csv file>"
  exit
end

def fetch_1_at_a_time(urls_filenames)

  easy = Curl::Easy.new
  easy.follow_location = true

  urls_filenames.each do|url_fn|
    easy.url = url_fn["url"]
    filename = url_fn["filename"]
    $stderr.print "filename:'#{filename}'"
    $stderr.print "url:'#{url_fn["url"]}'"
    if File.exist?(filename)
      $stderr.printf("skipping EXISTING filename:%s\n", filename)
      next
    end
    try_count = 0
    begin
      File.open(filename, 'wb') do|f|
        easy.on_progress {|dl_total, dl_now, ul_total, ul_now| $stderr.print "="; true }
        easy.on_body {|data| f << data; data.size }
        easy.perform
        $stderr.puts "=> '#{filename}'"
      end
    rescue Curl::Err::ConnectionFailedError => e
      try_count += 1
      if try_count < 4
        $stderr.printf("Curl:ConnectionFailedError exception, retry:%d\n",\
                       try_count)
        sleep(10)
        retry
      else
        $stderr.printf("Curl:ConnectionFailedError exception, retrying FAILED\n")
        raise e
      end
    end
  end
end

urls_filenames = []

CSV.foreach(URI.open(ARGV[0]), headers: true) do |p|
      id = p["id"]
      title = p["title"].gsub("/", " ")
      url = p["url_sq"]
      title = title[0..63] if title.length > 64
      datetaken = Time.parse(p["datetaken"])
      filename = sprintf("%4.4d-%2.2d-%2.2d-%2.2d-%2.2d-%2.2d-%d-%s.jpg", 
        datetaken.year, datetaken.month, datetaken.day, datetaken.hour,
        datetaken.min, datetaken.sec, id, title)
      $stderr.printf("photo:%d, title:%s url:%s filename:%s\n", id, title, url, filename)
      urls_filenames.push({"url"=> url, "filename" => filename}) if !url.nil?
end

$stderr.printf("FETCHING:%d originals\n", urls_filenames.length)
fetch_1_at_a_time(urls_filenames)