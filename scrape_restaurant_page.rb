def scrape_restaurant_page(restaurant_page_responses)
  #go through each restaurant response and scrape to your heart's content
  restaurant_page_responses.each do |geocode,response|
    #Get name of restaurant
    name = response.css("h1#HEADING.heading_name").text.strip

    #pages with 0 or 1 ratings have different page structures and will raise errors
    #set ratings and total ratings to nil... probably don't want to eat there
    begin
      #get total_ratings and individual breakdown of ratings (# of Excellent, Good, Ok, Bad, Terribe Reviews)
      total_ratings = response.css("a.more")[0].text.split(" ")[0]
      total_ratings.gsub!(",","")
      ratings = response.css("#ratingFilter ul").text.split(" ")
    rescue
      total_ratings = nil
      ratings = [nil]
    end

    #These weird indices give # of Excellent, Good, Ok, Bad, Terribe Reviews
    if ratings[0]
      ratings = ratings.select {|votes| ratings.index(votes) == 1 || ratings.index(votes) == 4 || ratings.index(votes) == 6 || ratings.index(votes) == 8 || ratings.index(votes) == 10}       #These indices give the number of Excellent, Very Good, Average, Poor and Terrible ratings respectively
    end

    #Save to db
    Restaurant.create(
    name: name ,
    city: MAP[extract_geocode(geocode)],
    total_ratings: total_ratings,
      #ratings is an array that was coerced into a string. Each element in the array is the number of excellent,good,okay,bad and terrible ratings respectively
      #the gsub removes the the square brackets and commas from stringified version of the array and creates and separates each tier of ratings with a space
    ratings: ratings.to_s.gsub(/[\\\"\[\]\,]/, '')
    )
  end
end
