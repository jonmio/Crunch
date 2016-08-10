require_relative "city" # All city level methods
require_relative "scrape_restaurant_page" # Gets and saves restaurant info to db
require_relative "restaurant" # Restaurant schema and class methods
require_relative "utility" # Utility methods


# Load html parser and http client
require "nokogiri"
require "rest-client"

=begin
To find restaurant information, you have to first start from the country page and find all the cities in the country by going through each page and scraping city links
  Ex. Canada => [Pg1,Pg2....]
  Ex. Canada Pg 1 => [Toronto, Vancouver....]

Then you have to visit the city page and go through all pages for each city
  Ex. Toronto => [Pg1, Pg2 ...]

On each page you collect the links to restaurants
  Ex. Toronto Pg1 => [placeholder.com, example.com, .....]

Then you can finally visit the restaurant link to scrape restaurant info
  Ex. placeholder.com => placeholder's ratings
=end


############# HANDLES INPUT

tripadvisor_root_url = "https://www.tripadvisor.ca/"
puts "Which country or city are you travelling to? Please use underscores instead of spaces"
country = gets.chomp()

while country.split(" ").length > 1
  puts "Invalid format. No spaces allowed. Please use underscores"
  country = gets.chomp()
end

resp = (RestClient.get "#{tripadvisor_root_url}#{country}").code.to_s

if resp.match(/40\d/)
  puts "Trip advisor does not support this country."
  exit
end


######### FINDS BASE INFORMATION (COUNTRY,GEOCODE)

# Visits "tripadvisor.ca/country" where country is the user's input and follows the redirect
country_page_url = "#{tripadvisor_root_url}#{country}"

end_of_url = RestClient.get(country_page_url).request.url.sub("https://www.tripadvisor.ca/Tourism-g","")

# The country code and the country name are found in the redirect URL
country_code = end_of_url.gsub(/[^\d]/, '')
country = end_of_url.split("-")[1]


########## GET LIST OF URLS FOR EACH CITY INDEX PAGE IN THE SPECIFIED COUNTRY

puts "getting cities"
city_index_links = get_city_index_links(country, country_code)
puts "done cities"


###### CREATE A CONSTANT (HASH) THAT MAPS GEOCODES TO CITY NAMES

# If user entered a city originally
if city_index_links == nil
  puts  "City name detected instead of country. Will continue to scrape CITY for restaurants"
  MAP= {"#{country_code}" => country}

else
  # Given a goeocde in a URL map will let us know which city the data belongs to
  MAP = get_map(city_index_links)
end


######### GETS A LINK TO EACH CITY PAGE (CONTAINS 30 RESTAURANT LINKS) AND COLLECTS LINKS TO RESTAURANTS

=begin
  Based on city_index_links and MAP we can access the page1 or index of every city.
  But the city can have more than 1 page of restaurants...
  Here we visit every page and collect all the restaurant links on each page
=end

puts "getting restaurant links"

urls_for_each_city = get_all_city_urls

city_responses = get_responses(urls_for_each_city)
100.times do
  puts "******************"
end

restaurant_urls = gather_restaurant_links_by_scraping(city_responses)


######### VISIT ALL RESTAURANT PAGES AND SCRAPE FOR RATING INFORMATION AND RESTAURANT INFO

restaurant_responses = get_responses(restaurant_urls)

scrape_restaurant_page(restaurant_responses)


########### APPLIES RANKING ALGORITHM and QUERIES DB FOR OUTPUT
Restaurant.calculate_scores
