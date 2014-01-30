require 'rubygems'
require 'sinatra'

# set :sessions, true
# run the following in the nitrous.io console shotgun -o 0.0.0.0 -p 3000 main.rb

# from www.chasepursley.com
# set port for compatibility with nitrous.io

configure :development do
  set :bind, '0.0.0.0'
  set :port, 3000
end

get '/' do
  "Hello, nitrous.io! Christian Rocks! Uche is Awesome!"
end

get '/inline' do
  "Hello, directly from the action \'inline\'"
end

get '/template' do
  erb :mytemplate #same as erb :mytemplate, layout: 'layout'
end

get '/nested_template' do
  erb :"/users/profile" #same as erb :"/users/profile", layout: 'layout'
end

get '/nothere' do
  redirect '/inline'
end




