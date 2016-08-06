require_relative "city"
require_relative "scrape_restaurant_page"
require_relative "restaurant"
require_relative "concurrent_pinging"
require_relative "misc"

require "rubygems"
require "pry"
# require "mechanize"
require "nokogiri"
require "net/http"
require "open-uri"
require "rest-client"

# multithread
# remove mechanize





# debugger
binding.pry
#
#
#
# #create new instance of mechanize to scrape page
# agent = Mechanize.new
#
#
# #input handling
tripadvisor_root_url = "https://www.tripadvisor.ca/"
#
# puts "Which country or city are you travelling to? Please use underscores instead of spaces"
# country = gets.chomp()
#
# while country.split(" ").length > 1
#   puts "Invalid format. No spaces allowed. Please use underscores"
#   country = gets.chomp()
# end
#
# #checks response at tripadvisor.ca/(country) to see if country is valid
# resp = Net::HTTP.get_response(URI.parse("#{tripadvisor_root_url}#{country}"))
#
# if resp.code.match(/40\d/)
#   puts "Trip advisor does not support this country."
#   exit
# end
NUM_THREADS = 10

country = "Monaco"
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
  $map= {"#{country_code}" => country}

  # city_names = ["#{country}"]
  # geocodes = ["#{country_code}"]

#if city_links is filled, the program will find all of the names for each city and the geocode tripadvisor associates with that city
else
  $map = get_map(city_links)
  # city_names = get_city_names(city_links)
  # geocodes = get_city_geocodes(city_links)
end
puts "getting restaurants links"
#Getting restuarnta links

urls_for_each_city = get_restaurant_urls
r = get_responses(urls_for_each_city)
all_rest_url = gather_restaurant_links_by_scraping(r)
scrape_rest_page(get_responses(all_rest_url))


# q = Queue.new
# city_pages = get_restaurant_urls(map)
# city_pages.each do |page|
#   q.push(page)
# end
#
# NUM_THREADS = 10
# links = []
# threads =[]
# semaphore = Mutex.new
# NUM_THREADS.times do
#   threads << Thread.new do
#     while q.length != 0
#       to_do = q.pop
#       city = to_do
#       res = (RestClient.get(to_do)).body
#       semaphore.synchronize{links << res}
#       sleep(1)
#     end
#   end
# end
#
# threads.each do |thread|
#   thread.join
# end
# q = Queue.new
# semaphore = Mutex.new
#
# all_rest = gather_restaurant_links_by_scraping(links)
puts "getting reviews"
# all_rest.each do |rest|
#   q.push(rest)
# end


#Stores urls that will be processed concurrently
# q = Queue.new
# semaphore = Mutex.new



# restaurant_links.each do |key, array|
#   array.length.times do |index|
#     city = key
#     link = array[index]
#     q.push([city,link])
#   end
# end

# restaurants = []
# threads =[]
#
# NUM_THREADS = 10
#
# NUM_THREADS.times do
#   threads << Thread.new do
#     while q.length != 0
#       to_do = q.pop
#       # city = to_do[0]
#       # link = to_do[1]
#       restaurant_info = scrape_restaurant_page(to_do)
#       semaphore.synchronize{restaurants << restaurant_info}
#       sleep(1)
#     end
#   end
# end
#
# threads.each do |thread|
#   thread.join
# end

restaurants_body = get_responses(all_rest_url)
scrape_rest_page(restaurants_body)
# restaurants.each do |restaurant_info|
#   Restaurant.create(
#   name: restaurant_info["name"],
#   city: restaurant_info["city"],
#   total_ratings: restaurant_info["total_ratings"],
#   #ratings is an array that was coerced into a string. Each element in the array is the number of excellent,good,okay,bad and terrible ratings respectively
#   #the gsub removes the the square brackets and commas from stringified version of the array and creates and separates each tier of ratings with a space
#   ratings: restaurant_info["ratings"].to_s.gsub(/[\\\"\[\]\,]/, ''),
#   country: country
#   )
# end
#
# #Goes through each city key and scrapes every restaurant url value and saves restaurant info to db
# restaurant_links.each do |key, array|
#   array.length.times do |index|
#     if running_thread_count > 10
#       puts "hello"
#       sleep(0.5)
#     end
#     threads << Thread.new {scrape_restaurant_page(key,"https://www.tripadvisor.ca/#{array[index]}")}
#     end
#   end
# end
#
# # restaurant_links.each do |key, array|
# #   array.length.times do |index|
# #     if running_thread_count > 10
# #       puts "hello"
# #       sleep(0.5)
# #     end
# #     threads << Thread.new {scrape_restaurant_page(key,"https://www.tripadvisor.ca/#{array[index]}")}
# #     end
# #   end
# # end
# binding.pry
# threads.each do |thread|
#   restaurant_info = thread.value
#   Restaurant.create(
#   name: restaurant_info["name"],
#   city: restaurant_info["city"],
#   total_ratings: restaurant_info["total_ratings"],
#   #ratings is an array that was coerced into a string. Each element in the array is the number of excellent,good,okay,bad and terrible ratings respectively
#   #the gsub removes the the square brackets and commas from stringified version of the array and creates and separates each tier of ratings with a space
#   ratings: restaurant_info["ratings"].to_s.gsub(/[\\\"\[\]\,]/, ''),
#   country: country
#   )
# end
#
# # restaurant_links.each do |key, array|
# #   array.length.times do |index|
# #     restaurant_info= scrape_restaurant_page(key,"https://www.tripadvisor.ca/#{array[index]}")
# #     Restaurant.create(
# #     name: restaurant_info["name"],
# #     city: restaurant_info["city"],
# #     total_ratings: restaurant_info["total_ratings"],
# #     #ratings is an array that was coerced into a string. Each element in the array is the number of excellent,good,okay,bad and terrible ratings respectively
# #     #the gsub removes the the square brackets and commas from stringified version of the array and creates and separates each tier of ratings with a space
# #     ratings: restaurant_info["ratings"].to_s.gsub(/[\\\"\[\]\,]/, ''),
# #     country: country
# #     )
# #     puts Restaurant.all.length
# #   end
# # end
#
# #sort restaurants and display ranked list
Restaurant.calculate_scores
