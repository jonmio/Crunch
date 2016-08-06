require_relative "city"
require_relative "scrape_restaurant_page"
require_relative "restaurant"
require_relative "concurrent_pinging"
require_relative "misc"

require "pry"
require "nokogiri"
require "rest-client"


#Initialize constant for thread pool
NUM_THREADS = 20


# debugger
binding.pry

#input handling
tripadvisor_root_url = "https://www.tripadvisor.ca/"

puts "Which country or city are you travelling to? Please use underscores instead of spaces"
country = gets.chomp()

while country.split(" ").length > 1
  puts "Invalid format. No spaces allowed. Please use underscores"
  country = gets.chomp()
end

#checks response at tripadvisor.ca/(country) to see if country is valid
resp = (RestClient.get "#{tripadvisor_root_url}#{country}").code.to_s

if resp.match(/40\d/)
  puts "Trip advisor does not support this country."
  exit
end


url_country = "#{tripadvisor_root_url}#{country}"

#going to tripadvisor.ca/(country) will always redirect to https://www.tripadvisor.ca/Tourism-g(country_code)-(country)-vacations.html"
end_link = RestClient.get(url_country).request.url.sub("https://www.tripadvisor.ca/Tourism-g","")
#takes only digits
country_code = extract_geocode(end_link)
#change country/city name to tripadvisor's version of the country name the user typed in.
country = end_link.split("-")[1]


puts "getting cities"
#returns an array of all of urls to acces each city in the country
city_links = get_city_links(country, country_code)
puts "done cities"

#city_links will be nill if a city is entered. If nill, country_code and country_name obtained above are actually city names and geocodes.
if city_links == nil
  puts  "Trip Advisor does not see this as as valid country. You have likely entered a city name. Will continue to scrape city for restaurants"
  MAP= {"#{country_code}" => country}

#if city_links is filled, the program will find all of the names for each city and the geocode tripadvisor associates with that city
else
  MAP = get_map(city_links)
end
puts "getting restaurants links"
#Getting restuarnta links

urls_for_each_city = get_restaurant_urls
r = get_responses(urls_for_each_city)
puts "getting reviews"
all_rest_url = gather_restaurant_links_by_scraping(r)
scrape_rest_page(get_responses(all_rest_url))

#sort restaurants and display ranked list
Restaurant.calculate_scores
