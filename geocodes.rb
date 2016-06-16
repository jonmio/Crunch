#Get geocodes
def get_geocodes (url_cities_in_iceland)
  geocode = url_cities_in_iceland.map do |city_links|       #geocode is a new array that contains a series of digits that are unique Trip advisor identifiers for each city that will be used later
    city_links.gsub(/[^\d]/, '')        #takes only numeric characters
  end
  return geocode
end
