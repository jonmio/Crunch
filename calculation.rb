require 'statistics2'

#Wilson's confidence interval method of ranking. Uses current number of votes as a sample of the whole population.
def ci_lower_bound(positive_ratings, total_ratings, confidence)
  #The confidence argument tells the ranking algorithm how aggresive it can be with its assumptions
  if total_ratings == 0
    return 0
  end
  z = Statistics2.pnormaldist(1-(1-confidence)/2)
  phat = 1.0*positive_ratings/total_ratings
  value = (phat + z*z/(2*total_ratings) - z * Math.sqrt((phat*(1-phat)+z*z/(4*total_ratings))/total_ratings))/(1+z*z/total_ratings)
  value*10**4
end

def sum_score_method1(ratings)
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
    return -1/(positive_ratings/60) + (positive_ratings/total_ratings)*2 - (standard_deviation)**2
  else
    return -1.0/0.0
  end
end

def sum_score_method2(ratings)
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
