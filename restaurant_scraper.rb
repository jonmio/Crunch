require 'rubygems'
require 'nokogiri'
require 'mechanize'
require 'restclient'


page=Nokogiri::HTML(RestClient.get "https://www.tripadvisor.ca/Restaurant_Review-g1184954-d6863237-Reviews-Gisli_Eirikur_Helgi_kaffihus_Bakkabraeora-Dalvik_Northeast_Region.html","User-Agent" => "Ruby/#{RUBY_VERSION}")
name = page.css("h1#HEADING.heading_name").text.strip
total_ratings = page.css("a.more")[0].text.split(" ")[0].to_s
ratings = page.css("#ratingFilter ul").text.split(" ")
ratings=ratings.select {|x| ratings.index(x)==1 || ratings.index(x)==4 ||ratings.index(x)==6 ||ratings.index(x)==8 || ratings.index(x)==10}
hash={}
hash['name'] = name
hash['total_ratings'] = total_ratings
hash['ratings'] = ratings
puts hash

agent = Mechanize.new
page = agent.get("https://www.tripadvisor.ca/Restaurant_Review-g1016825-d6363875-Reviews-Fossatun-Borgarbyggd_West_Region.html","User-Agent" => "Ruby/#{RUBY_VERSION}")
name= page.search("h1#HEADING.heading_name").text.strip
total_ratings = page.search("a.more")[0].text.split(" ")[0].to_s
ratings= page.search("#ratingFilter ul").text.split(" ")
ratings=ratings.select {|x| ratings.index(x)==1 || ratings.index(x)==4 ||ratings.index(x)==6 ||ratings.index(x)==8 || ratings.index(x)==10}
hash={}
hash['name'] = name
hash['total_ratings'] = total_ratings
hash['ratings'] = ratings
puts hash


#Make folder per city
