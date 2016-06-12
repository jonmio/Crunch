require 'rubygems'
require 'nokogiri'
require 'mechanize'
header={"User-Agent" => "Ruby/#{RUBY_VERSION}"}

agent = Mechanize.new
page = agent.get("https://www.tripadvisor.ca/Restaurants-g189952-Iceland.html",header)
page = page.search("div.geos_grid div.geo_name a")
arr=[]
page.each do |x|
  arr<<x['href']
end

baseurl= 'https://www.tripadvisor.ca/Restaurants-g189952-oa'
num=20
endurl="-Iceland.html#LOCATION_LIST'"
4.times do
  page = agent.get("#{baseurl}#{num.to_s}#{endurl}",header)
  num+=20
  page = page.search("div#LOCATION_LIST li a")
  page.each do |x|
    arr<<x['href']
  end
end






# name= page.search("h1#HEADING.heading_name").text.strip
# total_ratings = page.search("a.more")[0].text.split(" ")[0].to_s
# ratings= page.search("#ratingFilter ul").text.split(" ")
# ratings=ratings.select {|x| ratings.index(x)==1 || ratings.index(x)==4 ||ratings.index(x)==6 ||ratings.index(x)==8 || ratings.index(x)==10}
# hash={}
# hash['name'] = name
# hash['total_ratings'] = total_ratings
# hash['ratings'] = ratings
# puts hash


#Make folder per city
