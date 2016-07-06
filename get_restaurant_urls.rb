#Scrape each city page for restauraunt urls
def get_restaurant_urls(geocode, city_names)
  agent = Mechanize.new
  apistart = "https://www.tripadvisor.ca/RestaurantSearch?Action=PAGE&geo="
  apimiddle = "&ajax=1&sortOrder=popularity&o=a"
  apiend = "&availSearchEnabled=false"
  restaurant_links = {}

  #In each city page, tripadvisor dynamically loads content between differnet pages by making a call to an api. Only 2 cities have more than 1 page of restaurants
  (geocode.length).times do |city_number|       #loop goes through each city to collect all restaurant links in each of the cities
    begin
    agent.get("#{apistart}#{geocode[city_number]}#{apimiddle}0#{apiend}")
    rescue
      error = 404
      puts "Error for #{city_names[city_number]} w/ geocode #{geocode[city_number]} on page \# scraper"
    end
    restaurant_links["#{city_names[city_number]}"] = []      #Store urls in a hash with key = city name and values = links
    if error
      next
    end

    if agent.page.search("div.pageNumbers a").length > 0
      last_page_number = agent.page.search("div.pageNumbers a").last.text.to_i
    else
      last_page_number = 1
    end
    count = 0

    last_page_number.times do |city_page|

      contents = []

      #The api call returns the html for a page given the geocode of the city and another variable called count. Count starts at 0 and increments by 30 per page.
      agent.get("#{apistart}#{geocode[city_number]}#{apimiddle}#{count.to_s}#{apiend}")
      count += 30
      city_page = agent.page.search("div#EATERY_SEARCH_RESULTS a.property_title")       #Scrape api call
      city_page.each do |link_on_page|       #Loop to get each link
        contents << link_on_page['href']
      end
      contents.each do |links|        #Loop to put each link in hash
        restaurant_links["#{city_names[city_number]}"] << links
      end

      contents = []     #Empty array for next iteration
    end
  end
  return restaurant_links
end
