require_relative "get_city_links"
require_relative "get_city_names"
require_relative "get_city_geocodes"
require_relative "get_restaurant_urls"
require_relative "scrape_restaurant_page"
require_relative "restaurant"
require_relative "is_valid_country"
require_relative 'db_query'
require_relative "calculate_scores"
require "rubygems"
require "pry"
require "mechanize"
require "nokogiri"
require 'net/http'
require 'open-uri'


binding.pry
agent = Mechanize.new

tripadvisor_root_url = "https://www.tripadvisor.ca/"

country = is_valid_country #will usually lead to a redirect to the same country but in TA's preferred format
agent.get("#{tripadvisor_root_url}#{country}")
end_link = agent.page.uri.to_s.sub("https://www.tripadvisor.ca/Tourism-g","")
country_code = end_link.gsub(/[^\d]/,"")
country = end_link.split("-")[1] #change country name to proper TA's country format to prevent redirects

city_links = get_city_links(country, country_code)

if city_links == nil
  puts  "Trip Advisor does not see this as as valid country. You have likely entered a city name. Will continue to scrape city for restaurants"
  city_names = ["#{country}"]
  geocodes = ["#{country_code}"]
else
  city_names = get_city_names(city_links)
  geocodes = get_city_geocodes(city_links)
end

restaurant_links = get_restaurant_urls(geocodes, city_names)

restaurant_links.each do |key, array|
  array.length.times do |index|
    restaurant_info= scrape_restaurant_page(key,"https://www.tripadvisor.ca/#{array[index]}")
    Restaurant.create(
    name: restaurant_info['name'],
    city: restaurant_info['city'],
    total_ratings: restaurant_info['total_ratings'],
    ratings: restaurant_info['ratings'].to_s.gsub(/[\\\"\[\]\,]/, ''),
    country: country
    )
    puts Restaurant.all.length
  end
end
#
calculate_scores
#
#
puts "Done execution. How many top restuarants would you like to view"
num_restaurant = gets.chomp().to_i
db_query(num_restaurant)

#32690
