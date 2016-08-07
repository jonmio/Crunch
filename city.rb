def get_city_index_links(country,country_code)
  root_url = "https://www.tripadvisor.ca/Restaurants-g#{country_code}-"

  #This array will eventually contain the index urls for each city
  url_cities_in_country = []

  #Send get request
  country_page = get("#{root_url}#{country}.html")

  #Check if country has more than 1 page of cities
  if country_page.css("div.pageNumbers a").last
    #if more than one page find last page #
    last_page_number = country_page.css("div.pageNumbers a").last.text.to_i
  else
    last_page_number = 1
  end


  #Go through each page

  #For a given country, each page has a very similar format
  # Ex. https://www.tripadvisor.ca/Restaurants-g#{country_code}-oa{num}-#{country}.html#LOCATION_LIST
  # The only thing that changes between diff pages is num
  # It starts at 0 on page 1 and increases by 20 each page. (20 cities displayed per page)

  num = 0
  last_page_number.times do |page_number|

    #page 1 has different layout with diff css tags
    if page_number == 0
      country_page_showing_cities= get("#{root_url}oa#{num.to_s}-#{country}.html#LOCATION_LIST")

      #This CSS selector will return all anchor elments which are the city titles
      city_anchors = country_page_showing_cities.css("div.geos_grid div.geo_name a")

      #If user typed in a city instead of country, no cities will be scraped becase we are already on a "city level" page
      #Nil is returned. No point looping through each page to collect nothing
      if city_anchors.length == 0
        return nil
      end


      city_anchors.each do |links|
       #gets value of href attribute
        url_cities_in_country << links['href']
      end


    else
      country_page_showing_cities= get("#{root_url}oa#{num.to_s}-#{country}.html#LOCATION_LIST")
      city_anchors = country_page_showing_cities.css("div#LOCATION_LIST li a")

      city_anchors.each do |links|
        url_cities_in_country<<links['href']
      end
    end

    #Increment num by 20 to change url to reach next page on next iteration
    num += 20
  end

  return url_cities_in_country
end



def get_map (url_cities)
  map = {}
  #get city name and city geocode based on url from url_cities
  url_cities.each do |city_url|
    geocode = extract_geocode(city_url)
    name = city_url.split("-")[2].sub('.html',"")
    map[geocode] = name
  end
  return map
end






def get_all_city_urls
  #TA dynamically loads contact using AJAX so to acces the data, we can visit these api endpoints directly
  #Similar to the cities page, the urls are very similar
  # Ex. https://www.tripadvisor.ca/RestaurantSearch?Action=PAGE&geo=#{geocode}&ajax=1&sortOrder=popularity&o=a#{num}&availSearchEnabled=false
  # The only things that change are geocode (only for differnet cities)
  # If you're on the same city, num starts from 0 on page 1 for and increases by 30 per page (30 restaruants per page)
  # Map gives us access to all geocodes

  apistart = "https://www.tripadvisor.ca/RestaurantSearch?Action=PAGE&geo="
  apimiddle = "&ajax=1&sortOrder=popularity&o=a"
  apiend = "&availSearchEnabled=false"


  all_city_urls =[]

  #loop goes through each city by going through each geocode in MAP. Every geocode corresponds to 1 city
  MAP.each do |geocode,city_name|
    #Error handling for deadlinks and redirects. Pretty common for some countries....
    begin
    page = get("#{apistart}#{geocode}#{apimiddle}0#{apiend}")
    rescue
      #might not actually be a 404. but somethings wrong
      error = 404
      puts "Error for #{city_name} w/ geocodes #{geocode} on page \# scraper"
    end

    #skip page if there was an error
    if error
      next
    end

    #Scrape to determine # of pages for each city
    if page.search("div.pageNumbers a").length > 0
      last_page_number = page.search("div.pageNumbers a").last.text.to_i
    else
      last_page_number = 1
    end

    count = 0
    #generate these urls and append to all_city_urls
    last_page_number.times do |city_page|
      all_city_urls << "#{apistart}#{geocode}#{apimiddle}#{count.to_s}#{apiend}"
      count += 30
    end
  end
  all_city_urls
end


def gather_restaurant_links_by_scraping(res)
  response = []

  #res is a has containing key=geocode, values=response array
  res.each do |geocode, response_array|
    response_array.each do |page_body|
      response << page_body
    end
  end

  restaurant_links = []
  #scrape for restaurant links on each city page
  response.each do |page|
    #find href attribute of every anchor tag with class property_title on each page
    restaurant_links += page.css("a.property_title").map{|link| "https://www.tripadvisor.ca#{link['href']}"}
  end
  restaurant_links
end
