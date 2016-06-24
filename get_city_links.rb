def get_city_links(country,country_code)
  header = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}       #Header to identify scraper
  root_url = "https://www.tripadvisor.ca/Restaurants-g#{country_code}-"
  agent = Mechanize.new
  url_cities_in_country = [] #This array will contain the links that will display all of the restaurant_links for each city in Iceland


  agent.get("#{root_url}#{country}.html", header)
  last_page_number = agent.page.search("div.pageNumbers a").last.text.to_i
  num = 0


  last_page_number.times do |page_number|
    if page_number == 0 #page 1 has different layout
      agent.get("#{root_url}oa#{num.to_s}-#{country}.html#LOCATION_LIST", header)
      cities = agent.page.search("div.geos_grid div.geo_name a")  #This CSS selector will return all anchor elments which are the city titles
      cities.each do |links|
        url_cities_in_country << links['href']      #gets value of href attribute (link)
      end

    else
      agent.get("#{root_url}oa#{num.to_s}-#{country}.html#LOCATION_LIST", header)
      cities = agent.page.search("div#LOCATION_LIST li a")        #Use CSS selects to get links for cities. The selector is different than page 1 because TRIP advisor changes the page format.
      cities.each do |links|
        url_cities_in_country<<links['href']
      end
    end
    num += 20         #Increment num by 20 to change url to reach necity_numbert page
  end

  return url_cities_in_country
end
