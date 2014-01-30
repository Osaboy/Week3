# Simple site that has an index page, about page and contact page
# uses haml for the template

require 'rubygems'
require 'sinatra'
require 'haml'

configure :development do
  set :bind, '0.0.0.0'
  set :port, 3000
end

get '/index' do
  haml :index
end

get '/about' do
  haml :about
end

get '/contact' do
  haml :contact
end

__END__

@@layout
%html
  %body
= yield

@@index
# because of the code under @@layout, I no longer need the %html and %body line
#%html
#  %body
    %h1 Welcome

@@about
    %h1 About

@@index
    %h1 Contact