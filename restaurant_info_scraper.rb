# require 'restclient'

def scrape_restauraunt_page(city,url)
  agent = Mechanize.new       #create new mechanize object
  #send GET request to restaurant url
  page = agent.get(url, "User-Agent" => "Ruby/#{RUBY_VERSION}")  #some websites do not respond to scrapers that do not identify themselves
  name = page.search("h1#HEADING.heading_name").text.strip       #get name of restaurant with css selector

  begin     #pages with 0 or 1 ratings have different page structures and will raise errors, these restaurants have too few reviews to be ranked so they will be removed from the database
    total_ratings = page.search("a.more")[0].text.split(" ")[0]    #get total ratings
  rescue
    total_ratings = nil
  end

  begin     #pages with 0 or 1 ratings have different page structures and will raise errors, these restaurants have too few reviews to be ranked so they will be removed from the database
    ratings = page.search("#ratingFilter ul").text.split(" ")      #split string by whitespace
  rescue
    ratings = [nil]
  end

  if ratings[0]     #checks if ratings is nil
    ratings = ratings.select {|votes| ratings.index(votes) == 1 || ratings.index(votes) == 4 || ratings.index(votes) == 6 || ratings.index(votes) == 8 || ratings.index(votes) == 10}       #These indices give the number of Excellent, Very Good, Average, Poor and Terrible ratings respectively
  end
  #store information in restauraunt_info
  restaurant_info = {}
  restaurant_info['name'] = name
  restaurant_info['city'] = city
  restaurant_info['total_ratings'] = total_ratings.to_i
  restaurant_info['ratings'] = ratings
  return restaurant_info
end

##### THIS IS AN ALTERNATE WAY TO SCRAPE THE RESTAURANT PAGE BUT I FIND IT TO BE SLOWER

# page = Nokogiri::HTML(RestClient.get "https://www.tripadvisor.ca/Restaurant_Review-g1184954-d6863237-Reviews-Gisli_Eirikur_Helgi_kaffihus_Bakkabraeora-Dalvik_Northeast_Region.html","User-Agent" => "Ruby/#{RUBY_VERSION}")
# name = page.css("h1#HEADING.heading_name").text.strip
# total_ratings = page.css("a.more")[0].text.split(" ")[0]
# ratings = page.css("#ratingFilter ul").text.split(" ")
# ratings = ratings.select {|votes| ratings.index(votes) == 1 || ratings.index(votes) == 4 ||ratings.index(votes) == 6 || ratings.index(votes) == 8 || ratings.index(votes) == 10}
# restauraunt_info = {}
# restauraunt_info['name'] = name
# restauraunt_info['total_ratings'] = total_ratings
# restauraunt_info['ratings'] = ratings
