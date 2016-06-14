require_relative 'cities_scraper'
require_relative 'restaurant_scraper'

database = []
restaurant_links.each do |key, array|
  array.length.times do |index|
    database << scrape_restauraunt_page(key,"https://www.tripadvisor.ca/#{array[index]}")
  end
end

print database
print database.length

# get city urls
require 'rubygems'
require 'nokogiri'
require 'mechanize'
require_relative "restaurant_scraper"
  def get_city_url

  agent = Mechanize.new

   #Scrape page 1 of iceland cities
  page = agent.get("https://www.tripadvisor.ca/Restaurants-g189952-Iceland.html", "User-Agent" => "Ruby/#{RUBY_VERSION}") #Header to identify scraper
  page = page.search("div.geos_grid div.geo_name a")        #This CSS selector will return all anchor elments which are the city titles
  url_cities_in_iceland = []        #This array will contain the links that will display all of the restaurant_links for each city in Iceland

  page.each do |links|
    url_cities_in_iceland << links['href']      #gets value of href attribute (link)
  end

  #Scrape all other pages for iceland cities
  baseurl = 'https://www.tripadvisor.ca/Restaurants-g189952-oa'    #All other pages (not page 1) have the same url ecity_numbercept for two digits which increment by 20 per page
  num = 20
  endurl = "-Iceland.html#LOCATION_LIST'"
  4.times do        #There are four other pages to scrape
    page = agent.get("#{baseurl}#{num.to_s}#{endurl}", header)
    num+=20         #Increment num by 20 to change url to reach necity_numbert page
    page = page.search("div#LOCATION_LIST li a")        #Use CSS selects to get links for cities. The selector is different than page 1 because TRIP advisor changes the page format.
    page.each do |links|
      url_cities_in_iceland<<links['href']
    end
  end
  return url_cities_in_iceland
end

#Get geocodes
def get_geo_codes (url_cities_in_iceland)
  geocode = url_cities_in_iceland.map do |city_links|       #geocode is a new array that contains a series of digits that are unique Trip advisor identifiers for each city that will be used later
    city_links.gsub(/[^\d]/, '')        #takes only numeric characters
  end
  return geocode
end

#Get citynames
def get_city_names (url_cities_in_iceland)
  city_names = url_cities_in_iceland.map do |city_url|       #finds city name
    city_url.split("-")[-1].sub('.html',"")
  end
  return city_names
end

#Scrape each city page for restauraunt urls
def get_restaurant_urls(url_cities_in_iceland, geocode, city_names)
  apistart = "https://www.tripadvisor.ca/RestaurantSearch?Action=PAGE&geo="
  apimiddle = "&ajacity_number=1&itags=10591&sortOrder=popularity&o=a"
  apiend = "&availSearchEnabled=false"
  restaurant_links = {}

  #In each city page, tripadvisor dynamically loads content between differnet pages by making a call to an api. Only 2 cities have more than 1 page of restaurants
  (url_cities_in_iceland.length).times do |city_number|       #loop goes through each city to collect all restaurant links in each of the cities
    if city_number == 0       #Only the first two cities in url_cities_in_iceland array have more than 1 page, so the if and elsif statements handle them
      restaurant_links["#{city_names[city_number]}"] = []      #Store urls in a hash with key = city name and values = links
      count=0
      12.times do |city_page|       #Loops through city 0 12 times because it has 12 pages
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
        page= page.search("div#EATERY_SEARCH_RESULTS a.property_title")
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
      page = agent.get("https://www.tripadvisor.ca/#{url_cities_in_iceland[city_number]}")
      page = page.search("div#EATERY_SEARCH_RESULTS a.property_title")
      page.each do |link_on_page|
        restaurant_links["#{city_names[city_number]}"] << link_on_page['href']
      end
    end
  end
  return restaurant_links
end
