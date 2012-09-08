#!/usr/bin/env ruby

# Libraries:::::::::::::::::::::::::::::::::::::::::::::::::::::::
require 'rubygems'
#require 'redis'
require 'em-hiredis'
#require 'sinatra/base'
require 'sinatra/async'
require 'slim'
require 'sass'
require 'coffee-script'

STDOUT.sync = true

# Application:::::::::::::::::::::::::::::::::::::::::::::::::::
class SassHandler < Sinatra::Base
    
    set :views, File.dirname(__FILE__) + '/views/sass'
    
    get '/css/*.css' do
        filename = params[:splat].first
        sass filename.to_sym
    end
    
end

class CoffeeHandler < Sinatra::Base
    set :views, File.dirname(__FILE__) + '/views/coffee'
    
    get "/js/*.js" do
        filename = params[:splat].first
        coffee filename.to_sym
    end
end

class Click < Sinatra::Base
    use SassHandler
    use CoffeeHandler
    # register Async process
    register Sinatra::Async

    # Configuration:::::::::::::::::::::::::::::::::::::::::::::::
    set :public_folder, File.dirname(__FILE__) + '/public'
    set :views, File.dirname(__FILE__) + '/views'
    
    # Redis Setup:::::::::::::::::::::::::::::::::::::::::::::::::
    # redis = Redis.new

    # pub/sub...
 #   redis = EM::Hiredis.connect
 #   subscriber = EM::Hiredis.connect

    def connect!
        puts "connecting to redis"
        EM::Hiredis.connect
    end

    def redis
        @@redis ||= connect!
    end

    def subscribe!
        puts "subscribing to redis"
        EM::Hiredis.connect
    end

    def subscriber
        @@subscriber ||= subscribe!
    end

    # Route Handlers::::::::::::::::::::::::::::::::::::::::::::::
    get '/' do
        slim :index
    end

    aget('/new') do
        button_id = 1
        key = "button:#{button_id}:"+Time.now.to_i.to_s
        redis.incr(key) do
            redis.get(key) { |r| body "Hello #{r}" }
            redis.get(key) { |r| redis.publish(key, r)}
        end
    end

    aget '/sub' do
        button_id = 1
        subscriber.psubscribe("button:#{button_id}:*")
        subscriber.on(:pmessage) { |key, channel, message|
            body "Got #{channel}"
        }
    end
end

if __FILE__ == $0
    Click.run!
end