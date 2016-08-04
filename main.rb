require_relative "city"
require_relative "scrape_restaurant_page"
require_relative "restaurant"


require "rubygems"
require "pry"
require "mechanize"
require "nokogiri"
require "net/http"
require "open-uri"

#debugger
binding.pry

#create new instance of mechanize to scrape page
agent = Mechanize.new


#input handling
tripadvisor_root_url = "https://www.tripadvisor.ca/"

puts "Which country or city are you travelling to? Please use underscores instead of spaces"
country = gets.chomp()

while country.split(" ").length > 1
  puts "Invalid format. No spaces allowed. Please use underscores"
  country = gets.chomp()
end

#checks response at tripadvisor.ca/(country) to see if country is valid
resp = Net::HTTP.get_response(URI.parse("#{tripadvisor_root_url}#{country}"))

if resp.code.match(/40\d/)
  puts "Trip advisor does not support this country."
  exit
end


agent.get("#{tripadvisor_root_url}#{country}")
#going to tripadvisor.ca/(country) will always redirect to https://www.tripadvisor.ca/Tourism-g(country_code)-(country)-vacations.html"
end_link = agent.page.uri.to_s.sub("https://www.tripadvisor.ca/Tourism-g","")
#takes only digits
country_code = end_link.gsub(/[^\d]/,"")
#change country/city name to tripadvisor's version of the country name the user typed in.
country = end_link.split("-")[1]


puts "getting cities"
#returns an array of all of the cities in the country
city_links = get_city_links(country, country_code)
puts "done cities"

#city_links will be nill if a city is entered. If nill, country_code and country_name obtained above are actually city names and geocodes.
if city_links == nil
  puts  "Trip Advisor does not see this as as valid country. You have likely entered a city name. Will continue to scrape city for restaurants"
  city_names = ["#{country}"]
  geocodes = ["#{country_code}"]

#if city_links is filled, the program will find all of the names for each city and the geocode tripadvisor associates with that city
else
  city_names = get_city_names(city_links)
  geocodes = get_city_geocodes(city_links)
end
puts "getting restaurants links"
#Getting restuarnta links
restaurant_links = get_restaurant_urls(geocodes, city_names)
puts "getting reviews"
#Goes through each city key and scrapes every restaurant url value and saves restaurant info to db
restaurant_links.each do |key, array|
  array.length.times do |index|
    restaurant_info= scrape_restaurant_page(key,"https://www.tripadvisor.ca/#{array[index]}")
    Restaurant.create(
    name: restaurant_info["name"],
    city: restaurant_info["city"],
    total_ratings: restaurant_info["total_ratings"],
    #ratings is an array that was coerced into a string. Each element in the array is the number of excellent,good,okay,bad and terrible ratings respectively
    #the gsub removes the the square brackets and commas from stringified version of the array and creates and separates each tier of ratings with a space
    ratings: restaurant_info["ratings"].to_s.gsub(/[\\\"\[\]\,]/, ''),
    country: country
    )
    puts Restaurant.all.length
  end
end

#sort restaurants and display ranked list
Restaurant.calculate_scores
