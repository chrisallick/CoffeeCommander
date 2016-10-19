# $.ajax({
#     url: "http://192.168.9.249:9333/coffee/status/",
#     dataType: "jsonp"
# });

require 'sinatra'
require 'sinatra/partial'
require 'sinatra/reloader' if development?

require "sinatra/jsonp"

configure do
    redisUri = ENV["REDISTOGO_URL"] || 'redis://localhost:6379'
    uri = URI.parse(redisUri) 
    $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

    if $redis.get("coffee_status")
        $redis.set("coffee_status", $redis.get("coffee_status") )
    else
        $redis.set("coffee_status", "0" )
    end
end

get '/coffee/status/' do
    data = { :result => "success", :floor => "10", :button => "1", :state => "#{$redis.get("coffee_status")}" }.to_json
    JSONP data
end

get '/coffee/toggle/' do
    status = $redis.get("coffee_status")
    if status == "0"
        status = "1"
    else
        status = "0"
    end
    
    $redis.set("coffee_status", status)

    return "state: #{$redis.get("coffee_status")}"
end

get '/' do
    content_type :json

    return { :result => "success", :msg => "hello from Coffee Commander v1.0" }.to_json
end

not_found do
    return { :result => "error", :msg => "url not found" }.to_json
end