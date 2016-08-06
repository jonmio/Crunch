def extract_geocode(url)
  url.gsub(/[^\d]/, '')
end

def get(url)
  page = RestClient.get url, headers: {"User-Agent"=>"Ruby/#{RUBY_VERSION}"}
  Nokogiri::HTML(page.body)
end
