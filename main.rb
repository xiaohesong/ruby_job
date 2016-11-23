require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'redis'
require 'pry'
require 'json'

JOB_TITLE = 'ruby:job'
JOB_URL = 'https://ruby-china.org/jobs?page=1'
TWO_PAGE_COUNT = 2

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
  redirect '/ruby-china/jobs'

end

get '/ruby-china/jobs/:id' do
  id = params[:id]
  url = "https://ruby-china.org/topics/#{id}"
  page = Nokogiri::HTML(open(url))
  @title = page.at("div.media-body h1.media-heading")
  @body = page.at("div.panel-body.markdown article")
  erb :'/ruby-china/show'
end

get '/ruby-china/jobs' do
  @titles = {}
  size = (params[:page].to_i == 0 ? TWO_PAGE_COUNT : params[:page].to_i)
  size.times.each do |i|
    i = i + 1
    page = Nokogiri::HTML(open("https://ruby-china.org/jobs?page=#{i}"))
    list = page.search("div.title.media-heading a")
    list.each_with_index do |item, i|
      id ||= item.to_h["href"].split("/").last.to_i
      value ||= item.to_h["title"]
      @titles[id] = value
    end
  end
  erb :'ruby-china/index'
end

get '/lagou/jobs' do
  page = Nokogiri::HTML(open("https://www.lagou.com/jobs/list_Ruby?px=default&city=%E5%85%A8%E5%9B%BD#filterBox"))
  list = page.search("ul.item_con_list li")
  # binding.pry
end
