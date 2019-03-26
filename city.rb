=begin
  The city library provides city-level methods including methods that find the urls of each page of
  a city (Ex. Toronto1, Toronto2) and methods that collect the restaurant urls on every city page.
=end

def get_city_index_links(country,country_code)
  root_url = "https://www.tripadvisor.ca/Restaurants-g#{country_code}-"

  url_cities_in_country = []

  country_page = get("#{root_url}#{country}.html")

  # Find how many pages there are
  if country_page.css("div.pageNumbers a").last
    last_page_number = country_page.css("div.pageNumbers a").last.text.to_i
  else
    last_page_number = 1
  end

=begin
  For a given country, each page has a very similar format
  Ex. https://www.tripadvisor.ca/Restaurants-g#{country_code}-oa{num}-#{country}.html#LOCATION_LIST
  The only thing that changes between diff pages is num, which starts at 0 on page 1 and increases by 20 per page
=end

  num = 0
  last_page_number.times do |page_number|

    # page 1 has different layout with diff css tags
    if page_number == 0
      country_page_showing_cities= get("#{root_url}oa#{num.to_s}-#{country}.html#LOCATION_LIST")

      city_anchors = country_page_showing_cities.css("div.geos_grid div.geo_name a")

      # If user typed in a city instead of country, no cities will be scraped becase we are already on a "city level" page
      if city_anchors.length == 0
        return nil
      end


      city_anchors.each do |links|
        url_cities_in_country << links['href']
      end


    else
      country_page_showing_cities= get("#{root_url}oa#{num.to_s}-#{country}.html#LOCATION_LIST")
      city_anchors = country_page_showing_cities.css("div#LOCATION_LIST li a")

      city_anchors.each do |links|
        url_cities_in_country<<links['href']
      end
    end

    num += 20
  end

  return url_cities_in_country
end


def get_map (url_cities)
  #create map from url
  map = {}
  url_cities.each do |city_url|
    geocode = extract_geocode(city_url)
    name = city_url.split("-")[2].sub('.html',"")
    map[geocode] = name
  end
  return map
end


def get_all_city_urls
=begin
  TA dynamically loads contact using AJAX so to acces the data, we can visit these api endpoints directly
  The urls from page to page are once again very similar
  Ex. https://www.tripadvisor.ca/RestaurantSearch?Action=PAGE&geo=#{geocode}&ajax=1&sortOrder=popularity&o=a#{num}&availSearchEnabled=false
  The only things that change are geocode (only for differnet cities)
  If you're on the same city, num starts from 0 on page 1 for and increases by 30 per page (30 restaruants per page)
=end

  apistart = "https://www.tripadvisor.ca/RestaurantSearch?Action=PAGE&geo="
  apimiddle = "&ajax=1&sortOrder=popularity&o=a"
  apiend = "&availSearchEnabled=false"


  all_city_urls =[]

  # Loop goes through each city by going through each geocode in MAP
  MAP.each do |geocode,city_name|
    #Check for broken links
    begin
    page = get("#{apistart}#{geocode}#{apimiddle}0#{apiend}")
    rescue
      error = 404
      puts "Error for #{city_name} w/ geocodes #{geocode} on page \# scraper"
    end

    if error
      next
    end

    # Find # of pages to loop through
    if page.search("div.pageNumbers a").length > 0
      last_page_number = page.search("div.pageNumbers a").last.text.to_i
    else
      last_page_number = 1
    end

    count = 0
    # Generate a list of city urls
    last_page_number.times do |city_page|
      all_city_urls << "#{apistart}#{geocode}#{apimiddle}#{count.to_s}#{apiend}"
      count += 30
    end
  end
  all_city_urls
end


def gather_restaurant_links_by_scraping(res)
  response = []

  res.each do |geocode, response_array|
    response_array.each do |page_body|
      response << page_body
    end
  end

  restaurant_links = []
  response.each do |page|
    # Add links to restaraunts to putput array
    restaurant_links += page.css("a.property_title").map{|link| "https://www.tripadvisor.ca#{link['href']}"}
  end
  restaurant_links
end
