def get_city_links
  header = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}       #Header to identify scraper

  agent = Mechanize.new

   #Scrape page 1 of country's cities
  page = agent.get("https://www.tripadvisor.ca/Restaurants-g189952-Iceland.html", header)
  page = page.search("div.geos_grid div.geo_name a")        #This CSS selector will return all anchor elments which are the city titles
  url_cities_in_country = []        #This array will contain the links that will display all of the restaurant_links for each city in Iceland

  page.each do |links|
    url_cities_in_country << links['href']      #gets value of href attribute (link)
  end



  #Scrape all other pages for country's cities
  baseurl = 'https://www.tripadvisor.ca/Restaurants-g189952-oa'    #All other pages (not page 1) have the same url ecity_numbercept for two digits which increment by 20 per page
  num = 20
  endurl = "-Iceland.html#LOCATION_LIST'"
  4.times do        #There are four other pages to scrape
    page = agent.get("#{baseurl}#{num.to_s}#{endurl}", header)
    num+=20         #Increment num by 20 to change url to reach necity_numbert page
    page = page.search("div#LOCATION_LIST li a")        #Use CSS selects to get links for cities. The selector is different than page 1 because TRIP advisor changes the page format.
    page.each do |links|
      url_cities_in_iceland<<links['href']
    end
  end
  return url_cities_in_iceland
end
