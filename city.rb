require_relative "misc"
def get_city_links(country,country_code)
  root_url = "https://www.tripadvisor.ca/Restaurants-g#{country_code}-"
  # agent = Mechanize.new
  url_cities_in_country = [] #This array will contain the links that will display all of the restaurant_links for each city in Iceland


  country_page = get("#{root_url}#{country}.html")

  #check if country has more than one page
  if country_page.css("div.pageNumbers a").last
    #find the # of last pg
    last_page_number = country_page.css("div.pageNumbers a").last.text.to_i
  else
    last_page_number = 1
  end

  #Each page differs by 20 in the url, starting from 0 on page 1.
  num = 0

  #go through each page
  last_page_number.times do |page_number|
    #page 1 has different layout with diff css tags
    if page_number == 0
      country_page_showing_cities= get("#{root_url}oa#{num.to_s}-#{country}.html#LOCATION_LIST")
      #This CSS selector will return all anchor elments which are the city titles
      cities = country_page_showing_cities.css("div.geos_grid div.geo_name a")
      cities.each do |links|

       #gets value of href attribute (link)
        url_cities_in_country << links['href']
      end

    else
      cities = get("#{root_url}oa#{num.to_s}-#{country}.html#LOCATION_LIST").search("div#LOCATION_LIST li a")        #Use CSS selects to get links for cities. The selector is different than page 1 because TRIP advisor changes the page format.
      cities.each do |links|
        url_cities_in_country<<links['href']
      end
    end
    #Increment num by 20 to change url to reach necity_numbert page
    num += 20
  end


  #if user typed in a city instead of country, no cities will be scraped and nil is returned
  if url_cities_in_country.length == 0
    return nil
  else
    return url_cities_in_country
  end
end


def get_map (url_cities)
  map = {}
  #get city name and city geocode based on url
  url_cities.each do |city_url|
    geocode = extract_geocode(city_url)
    name = city_url.split("-")[-1].sub('.html',"")
    map[geocode] = name
  end
  return map
end


# def get_city_geocodes (url_cities)
#   #geocode is a new array that contains a series of digits that are unique Trip advisor identifiers for each city that will be used later
#   geocode = url_cities.map do |city_links|
#      #takes only numeric characters
#     city_links.gsub(/[^\d]/, '')
#   end
#   return geocode
# end



#Scrape each city page for restauraunt urls
def get_restaurant_urls
  apistart = "https://www.tripadvisor.ca/RestaurantSearch?Action=PAGE&geo="
  apimiddle = "&ajax=1&sortOrder=popularity&o=a"
  apiend = "&availSearchEnabled=false"
  # restaurant_links = {}
  urls =[]
  #In each city page, tripadvisor dynamically loads content between differnet pages by making an ajax call
  #loop goes through each city to collect all restaurant links in each of the cities
  $map.each do |k,v|
    begin
    page = get("#{apistart}#{k}#{apimiddle}0#{apiend}")
    rescue
      error = 404
      puts "Error for #{v} w/ geocodes #{k} on page \# scraper"
    end
     #Store urls in a hash with key = city name and values = links
     #Values will be filled from the loop below
    # restaurant_links["#{city_names[city_number]}"] = []

    if error
      next
    end

    #Find number of pages of restaurants per city
    if page.search("div.pageNumbers a").length > 0
      last_page_number = page.search("div.pageNumbers a").last.text.to_i
    else
      last_page_number = 1
    end
    #On page 1, count is euqual to 0 in the url. For each page, it increases by the number of restaurants listed on the page (30)
    count = 0

    last_page_number.times do |city_page|
      urls << "#{apistart}#{k}#{apimiddle}#{count.to_s}#{apiend}"
      count += 30
    end
  end
  urls
end


def gather_restaurant_links_by_scraping(res)
  res = res.values
  links = []
  res.each do |page|
    links += page.css("a.property_title").map{|link| "https://www.tripadvisor.ca#{link['href']}"}
  end
  links
end
#     #Go through each page
#     last_page_number.times do |city_page|
#
#       contents = []
#
#       #The api call returns the html for a page given the geocode of the city and another variable called count. Count starts at 0 and increments by 30 per page.
#       agent.get("#{apistart}#{geocodes[city_number]}#{apimiddle}#{count.to_s}#{apiend}")
#       count += 30
#       city_page = agent.page.search("div#EATERY_SEARCH_RESULTS a.property_title")
#       #Loop to get each link
#       city_page.each do |link_on_page|
#         contents << link_on_page['href']
#       end
#       #Fill hash value with links
#       contents.each do |links|        #Loop to put each link in hash
#         restaurant_links["#{city_names[city_number]}"] << links
#       end
#       #Empty array for next iteration
#       contents = []
#     end
#   end
#   return restaurant_links
# end
