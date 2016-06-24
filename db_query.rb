def db_query
  require 'restauraunt.rb'
  require 'rank'
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

  duplicates = Restaurant.select(:name,:ratings).group(:name,:ratings).having("count(*) > 1")
  duplicate_id = []
  duplicates.each do |restaurant|
    duplicate_id << Restaurant.find_by(name: restaurant.name) #Destroy one instance
  end
  Restaurant.destroy(duplicate_id)

  Restaurant.all.order(:score).last(10).each do |restaurant|
  puts restaurant.name
  end
  binding.pry
end


#Skatafell
#Heimaey Island
##CHECK for duplicate restuarants

#804 from generalized

#y=-1/(x/25)+score/total_rating
#var?

 #checks for minimum reviews to be considered #variance



#823
#1843 total
