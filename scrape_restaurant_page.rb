#This library scrapes a restaurant page and saves all relevant ratings and restaurant info to the db.

def scrape_restaurant_page(restaurant_page_responses)
  restaurant_page_responses.each do |geocode,responses|
    responses.each do |response|
      name = response.css("h1#HEADING.heading_name").text.strip

      # Pages with 0 or 1 ratings have different page structures and will raise errors
      begin
        total_ratings = response.css("a.more")[0].text.split(" ")[0]
        total_ratings.gsub!(",","")
        ratings = response.css("#ratingFilter ul").text.split(" ")
      rescue
        total_ratings = 0
        ratings = [0]
      end

      # Get # of Excellent, Good, Ok, Bad, Terribe Reviews
      if ratings[0] != 0
        ratings = ratings.select {|votes| ratings.index(votes) == 1 || ratings.index(votes) == 4 || ratings.index(votes) == 6 || ratings.index(votes) == 8 || ratings.index(votes) == 10}       #These indices give the number of Excellent, Very Good, Average, Poor and Terrible ratings respectively
      end
      Restaurant.create(
      name: name ,
      city: MAP[geocode],
      total_ratings: total_ratings,
        # Ratings is an array that was coerced into a string.
      ratings: ratings.to_s.gsub(/[\\\"\[\]\,]/, '')
      )
    end
  end
end
