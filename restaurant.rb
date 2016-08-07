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


  #Remove all duplicated restaurants if name of entry and ratings are the same. Sometimes TA displays the same restaurant in diff cities
  def self.remove_duplicates
    #find restaurants where name and rating are the same
    duplicates = Restaurant.select(:name,:ratings).group(:ratings, :name).having("count(*) > 1").all
    #Deletes duplicates and keeps 1 copy
    duplicates.each do |restaurant|
      while Restaurant.where(name: restaurant.name).where(ratings: restaurant.ratings).length > 1
        Restaurant.destroy(Restaurant.where(name: restaurant.name).where(ratings: restaurant.ratings).first.id)
      end
    end
  end


  #Searches database for the top n restaurants as specified by user
  def self.db_query(num)
    Restaurant.all.order(score: :desc).first(num).each do |restaurant|
      puts restaurant.name
    end
  end

  #Ranks the restaurant based on ratings and total ratings
  #Note that any method ending with method1 refers are used with wilson's confidence interval ranking algorithm while method2 refers to methods that are used with my own ranking algorithm
  #Currently wilson's confidence interval is being used. It works better with restaurants that have fewer reviews
  #To switch to my ranking algo, in calculate_scores
  # 1) replace sum_score_method1 with sum_score_method2,
  # 2) Comment out   restaurant.update(score: ci_lower_bound(positive_ratings,total_ratings,0.95))
  # 3) Uncomment line with sd = sd(ratings, total_ratings, positive_ratings)
  # 4) Uncomment restaurant.update(score: my_ranker(positive_ratings,total_ratings, sd))
  def self.calculate_scores
    Restaurant.all.each do |restaurant|
      ratings = restaurant.ratings.split(" ")
      ratings = ratings.map {|rating| rating.to_f}

      #Tally up ratings with heavy weighting on negative reviews
      positive_ratings = sum_score_method1(ratings)
      total_ratings = sum_total_ratings(ratings)
      # sd = sd(ratings, total_ratings, positive_ratings)
      if total_ratings != 0
        restaurant.update(score: ci_lower_bound(positive_ratings,total_ratings,0.95))
        # restaurant.update(score: my_ranker(positive_ratings,total_ratings, sd))
      else
        restaurant.update(score: 0)
      end
    end

    #Ask user how many entries they want to see
    puts "Done execution. How many top restuarants would you like to view"
    num_restaurant = gets.chomp().to_i
    Restaurant.remove_duplicates
    Restaurant.db_query(num_restaurant)
  end
end

#migration
Restaurant.auto_upgrade!
