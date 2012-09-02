#!/usr/bin/env ruby

# Libraries:::::::::::::::::::::::::::::::::::::::::::::::::::::::
require 'rubygems'
require 'sinatra/base'
require 'redis'
require 'slim'
require 'sass'
require 'coffee-script'

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
    #register Sinatra::Async

    # Configuration:::::::::::::::::::::::::::::::::::::::::::::::
    set :public_folder, File.dirname(__FILE__) + '/public'
    set :views, File.dirname(__FILE__) + '/templates'
    
    # Redis Setup:::::::::::::::::::::::::::::::::::::::::::::::::
    redis = Redis.new


    # Route Handlers::::::::::::::::::::::::::::::::::::::::::::::
    get '/' do
        slim :index
    end

    get('/new') do
        key = 'test'
        redis.incr(key)
        "Hello %s" % redis.get(key).to_s
    end

        
end

if __FILE__ == $0
    Click.run!
end