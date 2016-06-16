require_relative "cities_scraper"
require_relative "city_names"
require_relative "geocodes"
require_relative "restaurant_links"
require_relative "restaurant_info_scraper"
require_relative "restaurant"
require "rubygems"
require "mechanize"
require "nokogiri"



city_links = get_city_links
city_names = get_city_names(get_city_links)
geocodes = get_geocodes(get_city_links)

restaurant_links = get_restaurant_urls(city_links, geocodes, city_names)


restaurant_links.each do |key, array|
  array.length.times do |index|
    restaurant_info= scrape_restauraunt_page(key,"https://www.tripadvisor.ca/#{array[index]}")
    Restaurant.create(
    name: restaurant_info['name'],
    city: restaurant_info['city'],
    total_ratings: restaurant_info['total_ratings'],
    ratings: restaurant_info['ratings']
    )
  end
end

print database
print database.length
