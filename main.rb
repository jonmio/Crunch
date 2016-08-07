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




binding.pry
tripadvisor_root_url = "https://www.tripadvisor.ca/"









#############HANDLES INPUT
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




#########FINDS BASE INFORMATION (COUNTRY,GEOCODE)
country_page_url = "#{tripadvisor_root_url}#{country}"
#visits "tripadvisor.ca/"+country_user_inputted
#this will lead to a redirect to a url in the form of https://www.tripadvisor.ca/Tourism-g(country_code)-(country)-vacations.html"
end_of_url = RestClient.get(country_page_url).request.url.sub("https://www.tripadvisor.ca/Tourism-g","")
#get geocode form redirect url
country_code = extract_geocode(end_of_url)
#change country/city name to tripadvisor's version of the country name the user typed in
country = end_link.split("-")[1]







########## GET LIST OF URLS FOR EACH CITY IN THE SPECIFIED COUNTRY
puts "getting cities"
#get_city_links returns an array of urls that go to a city's index page
city_links = get_city_links(country, country_code)
puts "done cities"




###### CREATE A CONSTANT (HASH) THAT MAPS GEOCODES TO CITY NAMES
#city_links will be nill if a city was entered in place of a country by the user initially.
#this map will be used for reference later. Given any url, this hash can determine which city
#If nill, country_code and country_name obtained above are actually city names and geocodes.
if city_links == nil
  puts  "Trip Advisor does not see this as as valid country. You have likely entered a city name. Will continue to scrape city for restaurants"
  MAP= {"#{country_code}" => country}

#if city_links is filled, the program will find all of the names for each city and the geocode tripadvisor associates with that city
else
  MAP = get_map(city_links)
end








######### GETS A LINK TO EACH CITY PAGE OF RETAURANTS (CONTAINS 30 RESTAURANT LINKS) AND COLLECTS LINKS TO RESTAURANTS
puts "getting restaurant links"
#An array of urls for every city page

urls_for_each_city = get_restaurant_urls
#visits url
r = get_responses(urls_for_each_city)

1000.times do
  puts "******************"
end
#scrape each page for links to restaruants
#All rest url is an array of restaurant links
all_rest_url = gather_restaurant_links_by_scraping(r)









#########VISIT ALL RESTAURANT PAGES AND SCRAPE FOR RATING INFORMATION AND RESTAURANT INFO
#get response form each url
raw_restaurant_responses = get_responses(all_rest_url)
#scrape response for info and save to db
scrape_rest_page(raw_restaurant_responses)









###########APPLIES RANKING ALGORITHM AND SCORES RESTARAUNTS AND GIVES OUTPUT
Restaurant.calculate_scores
