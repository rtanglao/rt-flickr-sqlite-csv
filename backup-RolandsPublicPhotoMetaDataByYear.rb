#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'json'
require 'pp'
require 'time'
require 'date'
require 'parseconfig'
require 'typhoeus'
require 'awesome_print'
require 'csv'
require 'json_converter'

# yearly might not work if you take more than 4000 photos :-)
# https://www.flickr.com/services/api/flickr.photos.search.html
# Please note that Flickr will return at most the first 4,000 results for any given search query. 
# If this is an issue, we recommend trying a more specific query. 

def getFlickrResponse(url, params, logger)
    url = "https://api.flickr.com/" + url
    try_count = 0
    begin
      result = Typhoeus::Request.get(url,
                                   :params => params )
      x = JSON.parse(result.body)
     #logger.debug x["photos"].ai
    rescue JSON::ParserError => e
      try_count += 1
      if try_count < 4
        $stderr.printf("JSON::ParserError exception, retry:%d\n",\
                       try_count)
        sleep(10)
        retry
      else
        $stderr.printf("JSON::ParserError exception, retrying FAILED\n")
        x = nil
      end
    end
    return x
  end

  converter = JsonConverter.new
logger = Logger.new(STDERR)
logger.level = Logger::DEBUG

flickr_config = ParseConfig.new('flickr.conf').params
api_key = flickr_config['api_key']

if ARGV.length < 1
  puts "usage: #{$0} yyyy"
  exit
end

extras_str = "description, license, date_upload, date_taken, owner_name, icon_server,"+
             "original_format, last_update, geo, tags, machine_tags, o_dims, views,"+
             "media, path_alias, url_sq, url_t, url_s, url_m, url_z, url_l, url_o,"+
             "url_c, url_q, url_n, url_k, url_h, url_b"
MIN_DATE = Time.local(ARGV[0].to_i, 1, 1, 0, 0) # may want Time.utc if you don't want local time
MAX_DATE = Time.local(ARGV[0].to_i, 12, 31, 23, 59) # may want Time.utc if you don't want local time
             
min_taken_date  = MIN_DATE
max_taken_date  = MIN_DATE + (60 * 60 * 24) - 1
$stderr.printf("min_taken:%s max_taken:%s\n", min_taken_date, max_taken_date)
search_url = "services/rest/"
csv_array = []
while min_taken_date < MAX_DATE
  photos_to_retrieve = 250
  first_page = true
  photos_per_page = 0
  page = 1
  while photos_to_retrieve > 0
    url_params = {:method => "flickr.photos.search",
      :api_key => api_key,
      :format => "json",
      :nojsoncallback => "1", 
      :user_id => "35034347371@N01",
      :content_type => "7", # all: photos, videos, etc
      :per_page     => "250",
      :extras =>  extras_str,
      :sort => "date-taken-asc", 
      :page => page.to_s,
      :min_taken_date => min_taken_date.to_i.to_s,
      :max_taken_date => max_taken_date.to_i.to_s 
    }
    photos_on_this_page = getFlickrResponse(search_url, url_params, logger)
    if first_page
      first_page = false
      photos_per_page = photos_on_this_page["photos"]["perpage"].to_i
      photos_to_retrieve = photos_on_this_page["photos"]["total"].to_i - photos_per_page
    else
      photos_to_retrieve -= photos_per_page
    end
    page += 1
    $stderr.printf("STATUS from flickr API:%s retrieved page:%d of:%d\n", photos_on_this_page["stat"],
      photos_on_this_page["photos"]["page"].to_i, photos_on_this_page["photos"]["pages"].to_i)
    photos_on_this_page["photos"]["photo"].each do|photo|
      $stderr.printf("PHOTO datetaken from flickr API:%s\n", photo["datetaken"])
      skip = false
      begin
        datetaken = Time.parse(photo["datetaken"])
      rescue ArgumentError
        $stderr.printf("Parser EXCEPTION in date:%sSKIPPED\n",photo["datetaken"])
        skip = true
      end
      if skip 
        skip = false
        next
      end
      datetaken = datetaken.utc
      $stderr.printf("PHOTO datetaken:%s\n", datetaken)
      photo["datetaken"] = datetaken
      dateupload = Time.at(photo["dateupload"].to_i)
      $stderr.printf("PHOTO dateupload:%s\n", dateupload)
      photo["dateupload"] = dateupload
      lastupdate = Time.at(photo["lastupdate"].to_i)
      $stderr.printf("PHOTO lastupdate:%s\n", lastupdate)
      photo["cityphototaken"] = "vancouver.bc.canada"
      photo["lastupdate"] = lastupdate
      photo["id"] = photo["id"].to_i
      id = photo["id"]
      logger.debug "PHOTO id:" + id.to_s
      logger.debug photo.ai
      # id,owner,secret,server,farm,title,ispublic,isfriend,isfamily,license,description/_content,o_width,o_height,datetakengranularity,datetakenunknown,ownername,iconserver,iconfarm,views,tags,machine_tags,originalsecret,originalformat,latitude,longitude,accuracy,context,place_id,woeid,geo_is_public,geo_is_contact,geo_is_friend,geo_is_family,media,media_status,url_sq,height_sq,width_sq,url_t,height_t,width_t,url_s,height_s,width_s,url_m,height_m,width_m,url_z,height_z,width_z,url_l,height_l,width_l,url_o,height_o,width_o,url_c,height_c,width_c,url_q,height_q,width_q,url_n,height_n,width_n,url_k,height_k,width_k,url_h,height_h,width_h,pathalias
      photo["description_content"] = photo["description"]["_content"]
      photo_without_nested_stuff = photo.except("description")
      csv_array.push(photo_without_nested_stuff)
      #logger.debug photo.except("description").ai
      puts photo_without_nested_stuff
    end
  end
  min_taken_date += (60 * 60 * 24)
  max_taken_date += (60 * 60 * 24)
end
headers = csv_array[0].keys
#headers = [
#    "id","owner","secret","server","farm","title","ispublic","isfriend","isfamily","license","description/#_content","o_width","o_height","datetakengranularity","datetakenunknown","ownername","iconserver",#"iconfarm","views","tags","machine_tags","originalsecret","originalformat","latitude","longitude",#"accuracy","context","place_id","woeid","geo_is_public","geo_is_contact","geo_is_friend","geo_is_family",#"media","media_status","url_sq","height_sq","width_sq","url_t","height_t","width_t","url_s","height_s",#"width_s","url_m","height_m","width_m","url_z","height_z","width_z","url_l","height_l","width_l","url_o",#"height_o","width_o","url_c","height_c","width_c","url_q","height_q","width_q","url_n","height_n",#"width_n","url_k","height_k","width_k","url_h","height_h","width_h","pathalias"]
  FILENAME = sprintf("%s-roland-flickr-metadata.csv", 
    ARGV[0].to_i)
  CSV.open(FILENAME, "w", write_headers: true, headers: headers) do |csv_object|
    csv_array.each {|row_array| csv_object << row_array }
  end