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
    
    set :views, File.dirname(__FILE__) + '/templates/sass'
    
    get '/css/*.css' do
        filename = params[:splat].first
        sass filename.to_sym
    end
    
end

class CoffeeHandler < Sinatra::Base
    set :views, File.dirname(__FILE__) + '/templates/coffee'
    
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
    set :views, File.dirname(__FILE__) + '/templates'
    
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
        key = 'button-1'
        redis.incr(key) do
            redis.get(key) { |r| body "Hello #{r}" }
            #redis.publish(key, r)
            redis.publish(key, redis.get(key) { |r| body "#{r}"} )
        end
    end
 
end

if __FILE__ == $0
    Click.run!
end