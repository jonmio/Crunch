require 'rubygems'
require 'nokogiri'
require 'mechanize'
require 'pry'
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

arr_geocode=arr.map do |x|
  x.gsub(/[^\d]/, '')
end

arr_cities=arr.map do |x|
  x.split("-")[-1].sub('.html',"")
end


apistart = "https://www.tripadvisor.ca/RestaurantSearch?Action=PAGE&geo="
apimiddle = "&ajax=1&itags=10591&sortOrder=popularity&o=a"
apiend = "&availSearchEnabled=false"
restaurants = {}

(arr.length).times do |x|
  if x==0
    restaurants["#{arr_cities[x]}"] = []
    count=0
    12.times do |y|
      contents = []
      page=agent.get("#{apistart}#{arr_geocode[x]}#{apimiddle}#{count.to_s}#{apiend}")
      page= page.search("div#EATERY_SEARCH_RESULTS a.property_title")
      page.each do |z|
        contents << z['href']
      end
      contents.each do |z|
        restaurants["#{arr_cities[x]}"] << z
      end
      count += 30
      contents=[]
    end

  elsif x == 1
    restaurants["#{arr_cities[x]}"] = []
    count=0
    2.times do |y|
      contents = []
      page=agent.get("#{apistart}#{arr_geocode[x]}#{apimiddle}#{count.to_s}#{apiend}")
      page= page.search("div#EATERY_SEARCH_RESULTS a.property_title")
      page.each do |z|
        contents << z['href']
      end
      contents.each do |z|
        restaurants["#{arr_cities[x]}"] << z
      end
      count += 30
      contents=[]
    end
  else x == 67 || x == 72 || x== 89
    restaurants["#{arr_cities[x]}"] = []
    page = agent.get("https://www.tripadvisor.ca/#{arr[x]}")
    page = page.search("div#EATERY_SEARCH_RESULTS a.property_title")
    page.each do |z|
      restaurants["#{arr_cities[x]}"] << z['href']
    end
    puts restaurants["#{arr_cities[x]}"]
    puts restaurants.length
  end
end

# ##TEST
# #https://www.tripadvisor.ca/RestaurantSearch?Action=PAGE&geo=3567307&ajax=1&itags=10591&sortOrder=popularity&o=a0&availSearchEnabled=false
# page = agent.get("#{apistart}#{arr_geocode[89]}#{apimiddle}0#{apiend}")
# puts arr_geocode[89]
# puts page
# binding.pry
# page = page.search("div#EATERY_SEARCH_RESULTS a.property_title")
# puts page

# page.each do |x|
#   puts x['href']
# end
#API DOES NOT WORK FOR THOSE RESTAURANTS LEADS TO REDIRECT
#68,73,90
