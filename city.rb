def get_city_links(country,country_code)
  header = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}       #Header to identify scraper
  root_url = "https://www.tripadvisor.ca/Restaurants-g#{country_code}-"
  agent = Mechanize.new
  url_cities_in_country = [] #This array will contain the links that will display all of the restaurant_links for each city in Iceland


  agent.get("#{root_url}#{country}.html", header)
  if agent.page.search("div.pageNumbers a").last
    last_page_number = agent.page.search("div.pageNumbers a").last.text.to_i
  else
    last_page_number = 1
  end

  num = 0

  last_page_number.times do |page_number|
    if page_number == 0 #page 1 has different layout
      agent.get("#{root_url}oa#{num.to_s}-#{country}.html#LOCATION_LIST", header)
      cities = agent.page.search("div.geos_grid div.geo_name a")  #This CSS selector will return all anchor elments which are the city titles
      cities.each do |links|
        url_cities_in_country << links['href']      #gets value of href attribute (link)
      end

    else
      agent.get("#{root_url}oa#{num.to_s}-#{country}.html#LOCATION_LIST", header)
      cities = agent.page.search("div#LOCATION_LIST li a")        #Use CSS selects to get links for cities. The selector is different than page 1 because TRIP advisor changes the page format.
      cities.each do |links|
        url_cities_in_country<<links['href']
      end
    end
    num += 20         #Increment num by 20 to change url to reach necity_numbert page
  end

  if url_cities_in_country.length == 0
    return nil
  else
    return url_cities_in_country
  end
end


def get_city_names (url_cities)
  city_names = url_cities.map do |city_url|       #finds city name
    city_url.split("-")[-1].sub('.html',"")
  end
  return city_names
end


def get_city_geocodes (url_cities)
  geocode = url_cities.map do |city_links|       #geocode is a new array that contains a series of digits that are unique Trip advisor identifiers for each city that will be used later
    city_links.gsub(/[^\d]/, '')        #takes only numeric characters
  end
  return geocode
end


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
