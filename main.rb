#All city level methods
require_relative "city"
#Gets and saves restaurant info to db
require_relative "scrape_restaurant_page"
#Restaurant schema and class methods
require_relative "restaurant"
#Utility methods
require_relative "utility"

#debugger breakpoint
require "pry"
#HTML parser
require "nokogiri"
#HTTP client
require "rest-client"


#To find restaurant information, you have to first start from the country page and find all the cities in the country by going through each page and scraping city links
  #Ex. Canada => [Pg1,Pg2....]
  #Ex. Canada Pg 1 => [Toronto, Vancouver....]

#Then you have to visit the city page and go through all pages for each city
  #Ex. Toronto => [Pg1, Pg2 ...]

#On each page you collect the links to restaurants
  #Ex. Toronto Pg1 => [placeholder.com, example.com, .....]

#Then you can finally visit the restaurant link to scrape restaurant info
  #Ex. placeholder.com => placeholder's ratingss





binding.pry






#############HANDLES INPUT

tripadvisor_root_url = "https://www.tripadvisor.ca/"
puts "Which country or city are you travelling to? Please use underscores instead of spaces"
country = gets.chomp()

while country.split(" ").length > 1
  puts "Invalid format. No spaces allowed. Please use underscores"
  country = gets.chomp()
end

#checks if country is valid based on response code
resp = (RestClient.get "#{tripadvisor_root_url}#{country}").code.to_s
if resp.match(/40\d/)
  puts "Trip advisor does not support this country."
  exit
end

##########################################################################################




#########FINDS BASE INFORMATION (COUNTRY,GEOCODE)

country_page_url = "#{tripadvisor_root_url}#{country}"
#visits "tripadvisor.ca/country" where country is the user's input
#this will lead to a redirect to a url in the form of https://www.tripadvisor.ca/Tourism-g(country_code)-(country)-vacations.html"

end_of_url = RestClient.get(country_page_url).request.url.sub("https://www.tripadvisor.ca/Tourism-g","")
#the country code and the country name act as the starting points for our webscraping adventure

#get country code from redirect url
country_code = extract_geocode(end_of_url)

#change country/city name to tripadvisor's version of the country name the user typed in
country = end_of_url.split("-")[1]

##########################################################################################






########## GET LIST OF URLS FOR EACH CITY INDEX PAGE IN THE SPECIFIED COUNTRY

puts "getting cities"
city_index_links = get_city_index_links(country, country_code)
puts "done cities"

##########################################################################################




###### CREATE A CONSTANT (HASH) THAT MAPS GEOCODES TO CITY NAMES

#city_index_links will be nil if a city was entered in place of a country by the user initially.
#If nil, country_code and country_name obtained above are actually city names and geocodes.
if city_index_links == nil
  puts  "City name detected instead of country. Will continue to scrape CITY for restaurants"
  MAP= {"#{country_code}" => country}

#if city_index_links is filled, the program will find all of the names for each city and the geocode tripadvisor associates with that city
else
  #this map will be used for reference later. This hash will be used to determine which city a particular repsonse belongs to.
  #Impotant when we work with the db.
  MAP = get_map(city_index_links)
end

##########################################################################################




######### GETS A LINK TO EACH CITY PAGE (CONTAINS 30 RESTAURANT LINKS) AND COLLECTS LINKS TO RESTAURANTS
#Based on city_index_links and MAP we can access the page1 or index of every city. But the city can have more than 1 page of restaurants...
#Here we visit every page and collect all the restaurant links on each page
puts "getting restaurant links"

#An array of urls for every city page Ex. Toronto1,Toronto2...Vancouver1,Vancouver2.....
urls_for_each_city = get_all_city_urls

#Send request to each url and get response
city_responses = get_responses(urls_for_each_city)

1000.times do
  puts "******************"
end

#scrape each city page for links to restaruants
#restaurant_urls is an array of restaurant links
restaurant_urls = gather_restaurant_links_by_scraping(city_responses)

##########################################################################################








#########VISIT ALL RESTAURANT PAGES AND SCRAPE FOR RATING INFORMATION AND RESTAURANT INFO
#get response for each url
restaurant_responses = get_responses(restaurant_urls)
#scrape response for info and save to db
scrape_restaurant_page(restaurant_responses)

##########################################################################################








###########APPLIES RANKING ALGORITHM and QUERIES DB FOR OUTPUT
Restaurant.calculate_scores
##########################################################################################
