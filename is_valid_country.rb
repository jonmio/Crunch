def is_valid_country

  tripadvisor_root_url = "https://www.tripadvisor.ca/"

  puts "Which country are you travelling to? Please use underscores instead of spaces"
  country = gets.chomp()

  while country.split(" ").length > 1
    puts "Invalid format. No spaces allowed. Please use underscores"
    country = gets.chomp()
  end

  resp = Net::HTTP.get_response(URI.parse("#{tripadvisor_root_url}#{country}"))

  if resp.code.match(/40\d/)
    puts "Trip advisor does not support this country."
    exit
  end

  return country
end
