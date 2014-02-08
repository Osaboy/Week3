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
	    # else total += a.to_i == 0 ? 10 : a.to_i
	    end
	  end

	  # correct for Aces
	  arr.select{|e| e == "A"}.count.times do
	    total -= 10 if total > 21
	  end

	  return total
	end

	def card_image(card) # [ 'H' , '4' ]

	  pretty_suit = case card[0]
      when 'H' then 'hearts'
      when 'D' then 'diamonds'
      when 'S' then 'spades'
      when 'C' then 'clubs'
    end

    value = card[1]
    if ['J','Q','K','A'].include?(value)
    	value = case card[1]
	      when 'J' then 'jack'
	      when 'Q' then 'queen'
	      when 'K' then 'king'
	      when 'A' then 'ace'
	    end
    end

	  "<img src ='/images/cards/#{pretty_suit}_#{value}.jpg' class='card_image'>"

	end

	def did_player_win?()

		win_loose_draw = 0

		if calculate_total(session[:player_cards]) > calculate_total(session[:dealer_cards])
			win_loose_draw = 1
		elsif calculate_total(session[:player_cards]) < calculate_total(session[:dealer_cards])
			win_loose_draw = 0
		else
			win_loose_draw = 2
		end

		return win_loose_draw

	end

end

# this will run before all the actions below
before do 
	@show_hit_or_stay_buttons = true
	@show_dealer_card_buttons = false
end

get '/' do
	
	if session[:player_name]
		redirect '/game'
	else
		redirect '/new_player'
	end

end

get '/new_player' do
	erb :new_player
end

post '/new_player' do
  #binding.pry
  #session hash (limit of 4KB)
  
  if params[:player_name].empty?
  	@error = "Name is required!"
  	halt erb(:new_player)
  end

  session[:player_name] = params[:player_name] #param's from url parameters, name of input in erb file

  redirect '/game'
end

get '/game' do
	
	# Need to set up initial game values and render template

	# Create a deck and put it in session
	suits = ['H', 'D', 'S', 'C']
	cards = ['2', '3', '3', '4', '5', '6', '7', '8', '9', '10','J','Q','K','A']
	session[:deck] = suits.product(cards).shuffle!
	session[:player_cards]  = []
	session[:dealer_cards]  = []
	
	2.times do 
		session[:player_cards] << session[:deck].pop
		session[:dealer_cards] << session[:deck].pop
	end

	player_total = calculate_total(session[:player_cards])
	if player_total == 21
		@success = "Congratulations! #{session[:player_name]} hit blackjack!"
		@show_hit_or_stay_buttons = false
	end

	erb :game
end

post '/game/player/hit' do

	# deal new cards
	session[:player_cards] << session[:deck].pop

	player_total = calculate_total(session[:player_cards])

	if player_total == 21
		@success = "Congratulations! #{session[:player_name]} hit blackjack!"
		@show_hit_or_stay_buttons = false
	elsif player_total > 21
		@error = "Sorry, it looks like #{session[:player_name]} busted"
		@show_hit_or_stay_buttons = false
	end

	# render the template but do not redirect
	erb :game

end

post '/game/player/stay' do
	
	@success = "#{session[:player_name]} has chosen to stay."
	@show_hit_or_stay_buttons = false
	
	@success = "Dealers turn"

	dealer_total = calculate_total(session[:dealer_cards])

	if dealer_total == 21
		@success = "Sorry the dealer hit blackjack!"
		@show_hit_or_stay_buttons = false
	elsif dealer_total < 17
		@show_dealer_card_buttons = true
	else
		
		win_loose_draw = case did_player_win?()
			when 0 then
				@success ="Sorry dealer wins!" 
			when 1 then
				@success ="Congratulations #{session[:player_name]} wins!"
			when 2 then 
				@success ="Its a draw!"
			end
	end

	
	erb :game

end

post '/game/dealer/hit' do
	
	dealer_total = calculate_total(session[:dealer_cards])

	if dealer_total == 21
		@success = "Sorry the dealer hit blackjack!"
		@show_hit_or_stay_buttons = false
	end
	
	while dealer_total < 17
		
		session[:dealer_cards] << session[:deck].pop
		dealer_total = calculate_total(session[:dealer_cards])

		if dealer_total == 21
      @success = "Sorry the dealer hit blackjack!"
      @show_dealer_card_buttons = false 
    elsif dealer_total > 21
      @success = "Congratulations! dealer busted! #{session[:player_name]} wins!"
      @show_dealer_card_buttons = false
    else
    	# compare player_total to dealer_total

			win_loose_draw = case did_player_win?()
			when 0 then
				@success ="Sorry dealer wins!" 
			when 1 then
				@success ="Congratulations #{session[:player_name]} wins!"
			when 2 then 
				@success ="Its a draw!"
			end
    end
   
		@show_hit_or_stay_buttons = false
	end
	
	

	erb :game

end
