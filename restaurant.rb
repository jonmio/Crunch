#The restaurant class which includes the schema definition and class methods

require_relative 'calculation'

require 'active_record'
require 'mini_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'restaurant.sqlite3')

class Restaurant < ActiveRecord::Base
  field :name, as: :string
  field :city, as: :string
  field :total_ratings, as: :integer
  field :ratings, as: :string
  field :score, as: :integer


  # Remove all duplicated restaurants if name of entry and ratings are the same.
  def self.remove_duplicates
    duplicates = Restaurant.select(:name,:ratings).group(:ratings, :name).having("count(*) > 1").all
    duplicates.each do |restaurant|
      while Restaurant.where(name: restaurant.name).where(ratings: restaurant.ratings).length > 1
        Restaurant.destroy(Restaurant.where(name: restaurant.name).where(ratings: restaurant.ratings).first.id)
      end
    end
  end


  # Searches database for the top n restaurants
  def self.db_query(num)
    Restaurant.all.order(score: :desc).first(num).each do |restaurant|
      puts restaurant.name
    end
  end

=begin
  self.calculate_scores ranks the restaurant based on ratings and total ratings
  Note that any method ending with method1 refers to methods that are used with wilson's confidence interval ranking algorithm while method2 refers to methods that are used with my own ranking algorithm
  Currently wilson's confidence interval is being used. It works better with restaurants that have fewer reviews
  To switch to my ranking algo, in calculate_scores
  1) replace sum_score_method1 with sum_score_method2,
  2) Comment out   restaurant.update(score: ci_lower_bound(positive_ratings,total_ratings,0.95))
  3) Uncomment line with sd = sd(ratings, total_ratings, positive_ratings)
  4) Uncomment restaurant.update(score: my_ranker(positive_ratings,total_ratings, sd))
=end
  def self.calculate_scores
    Restaurant.all.each do |restaurant|
      ratings = restaurant.ratings.split(" ")
      ratings = ratings.map {|rating| rating.to_f}

      # Tally up ratings with heavy weighting on negative reviews
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

    puts "Done execution. How many top restuarants would you like to view"
    num_restaurant = gets.chomp().to_i
    Restaurant.remove_duplicates
    Restaurant.db_query(num_restaurant)
  end
end

Restaurant.auto_upgrade!
