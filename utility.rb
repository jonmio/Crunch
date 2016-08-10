# Reusable methods that aren't sepcific to any class or level of scraping

def extract_geocode(url)
  # Get geocode if url is valid
  if url.split("-")[1]
    url.split("-")[1].gsub(/[^\d]/, '')
  end
end


#Gets response body and wraps it in Nokogiri::HTML obj
def get(url)
  page = RestClient.get url, headers: {"User-Agent"=>"Ruby/#{RUBY_VERSION}"}
  Nokogiri::HTML(page.body)
end


# Initialize constant for thread pool
NUM_THREADS = 3


# Visits an array of urls without blocking main thread. It will return a hash with key=geocode and value=response
def get_responses(urls)
  # Queue instance is thread safe and holds all the urls that must be visited
  q = Queue.new

  semaphore = Mutex.new

  urls.each do |page|
    q.push(page)
  end

  return_values = {}

  threads =[]

  NUM_THREADS.times do
    # Thread keeps running as long as there is work to do on the queue
    # If empty, the thread will exit
    threads << Thread.new do
      while q.length != 0
        url = q.pop
        res = get(url)
        geocode = extract_geocode(url)
        semaphore.synchronize do
          if return_values.has_key?(geocode)
            return_values[geocode] << res
          else
            return_values[geocode] = [res]
          end
        end
        print "#{q.length}\n"
      end
    end
  end

  # ensure threads have finished running
  threads.each do |thread|
    thread.join
  end
  return_values
end
