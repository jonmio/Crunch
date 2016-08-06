def scrape_rest_page(json)
  json.each do |k,v|
    page = v
    name = page.css("h1#HEADING.heading_name").text.strip       #get name of restaurant with css selector
    begin     #pages with 0 or 1 ratings have different page structures and will raise errors, these restaurants have too few reviews to be ranked so they will be removed from the database
      total_ratings = page.css("a.more")[0].text.split(" ")[0]    #get total ratings
      total_ratings.gsub!(",","")
    rescue
      total_ratings = nil
    end

    begin     #pages with 0 or 1 ratings have different page structures and will raise errors, these restaurants have too few reviews to be ranked so they will be removed from the database
      ratings = page.css("#ratingFilter ul").text.split(" ")      #split string by whitespace
    rescue
      ratings = [nil]
    end

    if ratings[0]     #checks if ratings is nil
      ratings = ratings.select {|votes| ratings.index(votes) == 1 || ratings.index(votes) == 4 || ratings.index(votes) == 6 || ratings.index(votes) == 8 || ratings.index(votes) == 10}       #These indices give the number of Excellent, Very Good, Average, Poor and Terrible ratings respectively
    end
    Restaurant.create(
    name: name ,
    city: MAP[extract_geocode(k)],
    total_ratings: total_ratings,
      #ratings is an array that was coerced into a string. Each element in the array is the number of excellent,good,okay,bad and terrible ratings respectively
      #the gsub removes the the square brackets and commas from stringified version of the array and creates and separates each tier of ratings with a space
    ratings: ratings.to_s.gsub(/[\\\"\[\]\,]/, '')
    )
    # restaurant_info = {}
    # # #store information in restauraunt_info
    # restaurant_info['name'] = name
    # restaurant_info['city'] = city
    # restaurant_info['total_ratings'] = total_ratings.to_i
    # restaurant_info['ratings'] = ratings
    # restaurant_info
  end
end

# def scrape_restaurant_page(link)
#   # agent = Mechanize.new       #create new mechanize object
#   #send GET request to restaurant url
#   # page = agent.get(url, "User-Agent" => "Ruby/#{RUBY_VERSION}")  #some websites do not respond to scrapers that do not identify themselves
#
#     response = RestClient.get "https://www.tripadvisor.ca/#{url}", headers:{"User-Agent"=>"Ruby/#{RUBY_VERSION}" }
#     page= Nokogiri::HTML(response.body)
#
#     name = page.css("h1#HEADING.heading_name").text.strip       #get name of restaurant with css selector
#
#     begin     #pages with 0 or 1 ratings have different page structures and will raise errors, these restaurants have too few reviews to be ranked so they will be removed from the database
#       total_ratings = page.css("a.more")[0].text.split(" ")[0]    #get total ratings
#       total_ratings.gsub!(",","")
#     rescue
#       total_ratings = nil
#     end
#     #
#     begin     #pages with 0 or 1 ratings have different page structures and will raise errors, these restaurants have too few reviews to be ranked so they will be removed from the database
#       ratings = page.css("#ratingFilter ul").text.split(" ")      #split string by whitespace
#     rescue
#       ratings = [nil]
#     end
#     #
#     if ratings[0]     #checks if ratings is nil
#       ratings = ratings.select {|votes| ratings.index(votes) == 1 || ratings.index(votes) == 4 || ratings.index(votes) == 6 || ratings.index(votes) == 8 || ratings.index(votes) == 10}       #These indices give the number of Excellent, Very Good, Average, Poor and Terrible ratings respectively
#     end
#     restaurant_info = {}
#     # #store information in restauraunt_info
#     restaurant_info['name'] = name
#     restaurant_info['city'] = city
#     restaurant_info['total_ratings'] = total_ratings.to_i
#     restaurant_info['ratings'] = ratings
#     restaurant_info
# end
