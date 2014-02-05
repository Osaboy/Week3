require 'rubygems'
require 'sinatra'
require 'pry' # make sure that this is also included in the gem file


# run the following in the nitrous.io console shotgun -o 0.0.0.0 -p 3000 main.rb
set :sessions, true

# Define the helper methods
helpers do
  
  def calculate_total(cards) # [['Suit','Rank'],['Suit','Rank'],...]

	  arr = cards.map{ |e| e[1] }
	  total = 0

	  arr.each do |value|
	    if value == "A"
	      total += 11
	    elsif value.to_i == 0 # J, Q, K
	      total += 10
	    else
	      total += value.to_i
	    end
	  end

	  # correct for Aces
	  arr.select{|e| e == "A"}.count.times do
	    total -= 10 if total > 21
	  end

	  return total
	end
	
end

get '/' do

	erb :set_name
end

post '/set_name' do
  #binding.pry
  #session hash (limit of 4KB)
  session[:player_name] = params[:player_name]

  redirect '/game'
end

get '/game' do
	@test_variable = "I'm here to test"

	suits = ['H', 'D', 'S', 'C']
	cards = ['2', '3', '3', '4', '5', '6', '7', '8', '9', '10','J','Q','K','A']
	session[:deck] = suits.product(cards)
	session[:player_cards]  = []
	session[:dealer_cards]  = []
	
	2.times do 
		session[:player_cards] << session[:deck].pop
		session[:dealer_cards] << session[:deck].pop
	end

	erb :game
end

get '/test' do
  #binding pry
  @error = "something is wrong"
  erb :layout 
end