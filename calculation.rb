=begin
  This library is responsible for all calculations that are done to caculate the score of restaurants including
  summing up total # of reviews, summing total # of reviews, calculating score of restaurant and finding the standard deivaton
  of reviews.
=end
require 'statistics2'

# Wilson's confidence interval method of ranking. Uses current number of votes as a sample of the whole population.
def ci_lower_bound(positive_ratings, total_ratings, confidence)
  # The confidence argument tells the ranking algorithm how aggresive it can be with its assumptions
  if total_ratings == 0
    return 0
  end
  z = Statistics2.pnormaldist(1-(1-confidence)/2)
  phat = 1.0*positive_ratings/total_ratings
  value = (phat + z*z/(2*total_ratings) - z * Math.sqrt((phat*(1-phat)+z*z/(4*total_ratings))/total_ratings))/(1+z*z/total_ratings)
  value*10**4
end

def sum_score_method1(ratings)
=begin
  ci_lower_bound can only rank something if it only has 2 states of reviews - positive or neative.
  sum_score_method1 converts the ratings of a restaurant into these "binary" states and sums up the score of the restaurant
  Excellent = 2 positive, Good = 1, any other class of reviews are not positive so are not added to score
=end
  score = 0
  ratings.length.times do |index|
    case index
      when 0
        score += ratings[index]*2
      when 1
        score += ratings[index]
    end
  end
  return score
end

def sum_total_ratings(ratings)
=begin
  Counts total ratings, where excellent = 2, good = 1, okay =1, bad = 2, terrible = 4.
  Bad and terrible ratings are double weighted.
=end
  total_ratings = 0
  ratings.length.times do |index|
    case index
      when 0
        total_ratings += ratings[index]*2
      when 1
        total_ratings += ratings[index]
      when 2
        total_ratings += ratings[index]
      when 3
        total_ratings += ratings[index]*2
      when 4
        total_ratings += ratings[index]*4
    end
  end
  return total_ratings
end


def my_ranker(positive_ratings,total_ratings,standard_deviation)
  if positive_ratings > 0
=begin
    # First term ensures that restaurant has enough reviews to be considered but is asymtpotic in nature so it does not have a major impact after a certain point
    # Second term finds ratio of positive ratings
    # Third term subtracts the variance of the dataset. If a restaurant has very spread out reviews, this is a sign that it is inconsistent.
=end
    return -1/(positive_ratings/60) + (positive_ratings/total_ratings)*2 - (standard_deviation)**2
  else
    return -1.0/0.0
  end
end

def sum_score_method2(ratings)
=begin
  Here, excellent = 2, good = 1, okay =0, bad = -2, terrible = -4
  No longer need to assume binary state of reviews for my method of ranking
=end
  score = 0
  ratings.length.times do |index|
    case index
      when 0
        score += ratings[index]*2
      when 1
        score += ratings[index]
      when 3
        score += ratings[index]* -2
      when 4
        score += ratings[index]* -4
    end
  end
  return score
end

def sd (ratings,total_ratings,positive_ratings)
  # find standard deviation for dataset
  sq_diff = 0
  mean = positive_ratings/total_ratings
  ratings.length.times do |index|
    case index
      when 0
        sq_diff += ratings[index] * ((2 - mean)**2)
      when 1
        sq_diff += ratings[index] * ((1 - mean)**2)
      when 2
        sq_diff += ratings[index] * ((0 - mean)**2)
      when 3
        sq_diff += ratings[index] * ((-2-mean)**2)
      when 4
        sq_diff += ratings[index] * ((-4-mean)**2)
    end
    return Math.sqrt(sq_diff/total_ratings)
  end
end
