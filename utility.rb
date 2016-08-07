#Initialize constant for thread pool
NUM_THREADS = 3


def extract_geocode(url)
  url.gsub(/[^\d]/, '')
end

def get(url)
  page = RestClient.get url, headers: {"User-Agent"=>"Ruby/#{RUBY_VERSION}"}
  Nokogiri::HTML(page.body)
end

def get_responses(urls)
  q = Queue.new
  semaphore = Mutex.new

  #enque work
  urls.each do |page|
    q.push(page)
  end

  #results
  response_bodies = {}
  #holds thread objects
  threads =[]

  NUM_THREADS.times do
    threads << Thread.new do
      while q.length != 0
        url = q.pop
        res = get(url)
        semaphore.synchronize{response_bodies[extract_geocode(url)] = res}
        print "#{q.length}\n"
      end
    end
  end

  #ensure finish
  threads.each do |thread|
    thread.join
  end
  return response_bodies
end
