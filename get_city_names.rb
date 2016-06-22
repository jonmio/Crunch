#Get citynames
def get_city_names (url_cities)
  city_names = url_cities.map do |city_url|       #finds city name
    city_url.split("-")[-1].sub('.html',"")
  end
  return city_names
end
