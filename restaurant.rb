#All methods used to calculate the score of a restaurant are found in calculation.rb
require_relative 'calculation'

require 'active_record'
require 'mini_record'

#Map class to a relational db table
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'restaurant.sqlite3')

class Restaurant < ActiveRecord::Base
  #set schema
  field :name, as: :string
  field :city, as: :string
  field :total_ratings, as: :integer
  field :ratings, as: :string
  field :score, as: :integer
  field :country, as: :string


  #Remove all duplicated restaurants if name of entry and ratings are the same. Sometimes TA displays the same restaurant in diff cities
  def self.remove_duplicates
    # duplicates = Restaurant.select(:name,:ratings).group(:country,:ratings, :name).having("count(*) > 1").all
    #returns name and ratings of duplicated restuarant
    duplicates = Restaurant.select(:name,:ratings).group(:ratings, :name).having("count(*) > 1").all
    #Saves one copy of the restaurant and delete the other duplicates in the database
    duplicates.each do |restaurant|
      cache = Restaurant.where(name: restaurant.name).where(ratings: restaurant.ratings).first
      Restaurant.where(name: restaurant.name).where(ratings: restaurant.ratings).destroy_all
      Restaurant.create(
      name: cache.name,
      country: cache.country,
      city: cache.city,
      ratings: cache.ratings,
      score: cache.score,
      total_ratings: cache.total_ratings
      )
    end
  end


  #Searches database for the top n restaurants as specified by user
  def self.db_query(num)
    Restaurant.all.order(score: :desc).first(num).each do |restaurant|
      puts restaurant.name
    end
  end

  #Ranks the restaurant based on ratings and total ratings
  #Note that method1 refers to a series of methods used to rank the restaurant using wilson's confidence interval while method2 refers to methods to use with my own ranking algorithm
  #To switch to my ranking algo, replace sum_score_method1 with sum_score_method2, call sd method for each restaurant in the loop below and use the existing code for total_ratings. Pass these values into my_ranker in place of ci_lower_bound
  def self.calculate_scores
    Restaurant.all.each do |restaurant|
      ratings = restaurant.ratings.split(" ")
      ratings = ratings.map {|rating| rating.to_f}

      #Tally up ratings with heavy weighting on negative reviews.
      positive_ratings = sum_score_method1(ratings)
      total_ratings = sum_total_ratings(ratings)
      if total_ratings != 0
        restaurant.update(score: ci_lower_bound(positive_ratings,total_ratings,0.95))
      else
        restaurant.update(score: 0)
      end
    end
    puts "Done execution. How many top restuarants would you like to view"
    num_restaurant = gets.chomp().to_i
    Restaurant.remove_duplicates
    Restaurant.db_query(num_restaurant)
  end
end

#migration
Restaurant.auto_upgrade!
