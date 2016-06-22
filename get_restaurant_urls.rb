#Scrape each city page for restauraunt urls
def get_restaurant_urls(url_cities, geocode, city_names)
  agent = Mechanize.new
  apistart = "https://www.tripadvisor.ca/RestaurantSearch?Action=PAGE&geo="
  apimiddle = "&ajax=1&sortOrder=popularity&o=a"
  apiend = "&availSearchEnabled=false"
  restaurant_links = {}

  #In each city page, tripadvisor dynamically loads content between differnet pages by making a call to an api. Only 2 cities have more than 1 page of restaurants
  (url_cities.length).times do |city_number|       #loop goes through each city to collect all restaurant links in each of the cities
    if city_number == 0       #Only the first two cities in url_cities_in_iceland array have more than 1 page, so the if and elsif statements handle them
      restaurant_links["#{city_names[city_number]}"] = []      #Store urls in a hash with key = city name and values = links
      count=0
      14.times do |city_page|       #Loops through city 0 13 times because it has 13 pages
        contents = []

        #The api call returns the html for a page given the geocode of the city and another variable called count. Count starts at 0 and increments by 30 per page.

        page = agent.get("#{apistart}#{geocode[city_number]}#{apimiddle}#{count.to_s}#{apiend}")
        page= page.search("div#EATERY_SEARCH_RESULTS a.property_title")       #Scrape api call
        page.each do |link_on_page|       #Loop to get each link
          contents << link_on_page['href']
        end
        contents.each do |links|        #Loop to put each link in hash
          restaurant_links["#{city_names[city_number]}"] << links
        end
        count += 30     #Increase count to get to next page ############MUST FIX
        contents = []     #Empty array for next iteration
      end


    elsif city_number == 1        #Only the first two cities in url_cities_in_iceland array have more than 1 page.
      restaurant_links["#{city_names[city_number]}"] = []
      count = 0
      2.times do |city_page|      #Loops through city 1, 2 times becuase it has 2 pages
        contents = []
        page = agent.get("#{apistart}#{geocode[city_number]}#{apimiddle}#{count.to_s}#{apiend}")
        page = page.search("div#EATERY_SEARCH_RESULTS a.property_title")
        page.each do |link_on_page|
          contents << link_on_page['href']
        end
        contents.each do |links|
          restaurant_links["#{city_names[city_number]}"] << links
        end
        count += 30
        contents = []
      end



    #The other cities have only 1 page of restaurants so the api call is not needed. The city url_cities_in_iceland can be used to directly reach the page.
    else
      restaurant_links["#{city_names[city_number]}"] = []
      page = agent.get("https://www.tripadvisor.ca/#{url_cities[city_number]}")
      page = page.search("div#EATERY_SEARCH_RESULTS a.property_title")
      page.each do |link_on_page|
        restaurant_links["#{city_names[city_number]}"] << link_on_page['href']
      end
    end
  end
  return restaurant_links
end
