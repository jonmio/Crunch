require 'active_record'
require 'mini_record'
require 'statistics2'
require 'pry'


ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'restaurant.sqlite3')

class Restaurant < ActiveRecord::Base
  field :name, as: :string
  field :city, as: :string
  field :total_ratings, as: :integer
  field :ratings, as: :string
  field :score, as: :integer
end

Restaurant.auto_upgrade!

def ci_lower_bound(pos, n, confidence)
  if n == 0
    return 0
  end
  z = Statistics2.pnormaldist(1-(1-confidence)/2)
  phat = 1.0*pos/n
  value = (phat + z*z/(2*n) - z * Math.sqrt((phat*(1-phat)+z*z/(4*n))/n))/(1+z*z/n)
  value*10**8
end

Restaurant.all.each do |restaurant|
  ratings = restaurant.ratings.split(' ')
  total_ratings = 0
  score = 0
  ratings.length.times do |index|
    case index
      when 0
        total_ratings += ratings[index].to_i*2
        score += ratings[index].to_i*2
      when 1
        total_ratings += ratings[index].to_i
        score += ratings[index].to_i
      when 3
        total_ratings += ratings[index].to_i*2
      when 4
        total_ratings += ratings[index].to_i*4
    end
  end
  restaurant.update(score: ci_lower_bound(score,total_ratings,0.95))
end

Restaurant.all.order(:score).last(100).each do |restaurant|
  puts restaurant.name
end



#y=-1/(x/25)+score/total_rating
#var?

 #checks for minimum reviews to be considered



#823
#1843 total
