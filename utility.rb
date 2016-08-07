#Reusable methods that aren't sepcific to any class or level of scraping

def extract_geocode(url)
  #string will only containg digits giving the desired geocode
  url.gsub(/[^\d]/, '')
end



#sends a get request and wraps it as a Nokogiri object for easy scraping with css selectors
def get(url)
  #some websites prohibit acces without user-agent header
  page = RestClient.get url, headers: {"User-Agent"=>"Ruby/#{RUBY_VERSION}"}
  Nokogiri::HTML(page.body)
end




#Initialize constant for thread pool
NUM_THREADS = 3

#I have 4 cores but setting NUM_THREADS to 4 just wrecks my computer


#get_responses takes an array of urls and visits the urls without blocking the main thread. it will return a hash with key=geocode and value=response
def get_responses(urls)
  #Queue instance is thread safe and holds all the urls that must be visited
  q = Queue.new

  #Semaphore locks shared resources and ensures sychronized access
  semaphore = Mutex.new

  #enqueue work
  urls.each do |page|
    q.push(page)
  end

  return_values = {}

  #holds thread objects, so they can be processed later
  threads =[]

  NUM_THREADS.times do
    #Thread keeps running as long as there is work to do on the queue
    #If empty, the thread will exit
    threads << Thread.new do
      while q.length != 0
        url = q.pop
        res = get(url)
        semaphore.synchronize{return_values[extract_geocode(url)] = res}
        print "#{q.length}\n"
      end
    end
  end

  #ensure threads have finished running
  threads.each do |thread|
    thread.join
  end
  return_values
end
