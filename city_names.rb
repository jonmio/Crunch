#Get citynames
def get_city_names (url_cities_in_iceland)
  city_names = url_cities_in_iceland.map do |city_url|       #finds city name
    city_url.split("-")[-1].sub('.html',"")
  end
  return city_names
end
