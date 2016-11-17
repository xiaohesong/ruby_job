require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'redis'
require 'pry'
require 'json'

JOB_TITLE = 'ruby:job'

configure :production do
  uri = URI.parse(ENV["REDISGREEN_URL"])
  $redis = Redis.new(url: ENV["REDISGREEN_URL"], driver: :hiredis)
end

configure :test do
  $redis = Redis.new(url: ENV["WERCKER_REDIS_URL"], driver: :hiredis)
end

configure :development do
  $redis = Redis.new()
end

get '/' do
    @titles = {}
    url = 'https://ruby-china.org/jobs'
    page = Nokogiri::HTML(open(url))
    list = page.search("div.title.media-heading a")
    list.each_with_index do |item, i|
      id ||= item.to_h["href"].split("/").last.to_i
      value ||= item.to_h["title"]
      # puts "这个id是#{id},value是#{value}, 序号是#{i}"
      @titles[id] = value
      # @titles << Hash[id]
    end
    erb :index
end
