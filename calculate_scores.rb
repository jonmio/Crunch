require_relative 'ranking_calculations'
require_relative 'restaurant'

def calculate_scores
  Restaurant.all.each do |restaurant|
      ratings = restaurant.ratings.split(' ')
      ratings = ratings.map {|rating| rating.to_f}
      positive_ratings = sum_score_method1(ratings)
      total_ratings = sum_total_ratings(ratings)
      if total_ratings != 0
        restaurant.update(score: ci_lower_bound(positive_ratings,total_ratings,0.95))
      else
        restaurant.update(score: 0)
      end
    end
end



#Below is the ranking algo i created.

# def calculate_scores
#   Restaurant.all.each do |restaurant|
#     ratings = restaurant.ratings.split(' ')
#     ratings = ratings.map {|rating| rating.to_f}
#     total_ratings = restaurant.total_ratings
#
#     if total_ratings != 0
#       positive_ratings = sum_score_method2(ratings)
#       standard_deviation = sd(ratings,total_ratings,positive_ratings)
#       restaurant.update(score: rank(positive_ratings,total_ratings,standard_deviation))
#     else
#       restaurant.update(score: -1.0/0.0)
#     end
#   end
# end
