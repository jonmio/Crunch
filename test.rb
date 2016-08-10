###########Tested gems

# require "unirest"
# require "pry"
# require "restclient"
# # require "eventmachine"
# require "em-http-request"
# require "typhoeus"
# require "thread"
# puts Process.pid
#
# queue = Queue.new
# 1000.times do |x|
#   queue.push(x)
# end
# threads = []
# 5.times do
#
#   threads << Thread.new do
#     while queue.length > 0
#       print "#{queue.pop}\n"
#     end
#   end
# end
# sleep(2)
# binding.pry
# threads.each do |thread|
#   thread.join
# end
# # restaurants = []
# # threads =[]
# #
# # queue.push("hi")
# # NUM_THREADS = 5
# #
# # NUM_THREADS.times do
# #   threads << Thread.new do
# #     # loop do
# #       to_do = queue.pop
# #       city = to_do[0]
# #       link = to_do[1]
# #       restaurant_info = scrape_restaurant_page(city,link)
# #       semaphore.synchronize{restaurants << restaurant_info}
# #       sleep(1)
# #     # end
# #   end
# # end
# # binding.pry
# # puts Thread.list
# #
# #
# # threads.each do |thread|
# #   while thread.status == "run"
# #     sleep(0.1)
# #   end
# #   thread.exit
# # end
# #
# # binding.pry
# # 100.times do |x|
# #   queue.push(x)
# # end
# #
# # threads = []
# # # Start 2 threads to pop work off of the queue and print it, then sleep 3 seconds for effect
# # 10.times do
# #   threads << Thread.new do
# #     loop do
# #       queue_item = queue.pop
# #
# #     end
# #   end
# # end
# #
# #
# # threads.each do |thread|
# #   while !thread.stop?
# #     sleep(0.5)
# #   end
# #   thread.exit
# # end
# #
# # loop do
# #   puts "Hi"
# # end
# #
# #
# # # threads.each do |thread|
# # #   thread.join
# # # end
# # # queue.clear
# # # Process.exit(0)
# # # trap "INT" do
# # #   # Remove any queued jobs from the list
# # #   queue.clear
# # #
# # #   # Wait until any currently running threads have finished their current work and returned to queue.pop
# # #   while queue.num_waiting < threads.count
# # #     pending_threads = threads.count - queue.num_waiting
# # #     puts "Waiting for #{pending_threads} threads to finish"
# # #     sleep 1
# # #   end
# # #
# # #   # Kill off each thread now that they're idle and exit
# # #   threads.each(&:exit)
# # #   Process.exit(0)
# # # end
# # # loop do
# # #   puts "hi"
# # # end
# # # Add 5 items to the queue to be processed by the threads above
# # # 5.times do |n|
# # #   queue.push "Item #{n}"
# # # end
# #
# #
# # # def running_thread_count
# # #   Thread.list.select {|thread| thread.status == "run"}.count
# # # end
# #
# # # urls = []
# # # 100.times do |x|
# # #   urls << "http://karinamio.com"
# # # end
# # #
# # # NUM_THREADS = 8
# # # res = []
# # #
# # #
# # # #sync global or new threads with no sync
# # # NUM_THREADS.times.map{
# # #   Thread.new(urls) do |urls|
# # #     while urls.length > 0
# # #       url = urls.pop
# # #       r = RestClient.get url
# # #       res << r
# # #     end
# # #   end
# # # }.each(&:join)
# # #
# # # binding.pry
# #
# #
# #
# # # threads =[]
# # # 500.times do |x|
# # #   if running_thread_count > 30
# # #     sleep(1)
# # #   end
# # #   threads << Thread.new do
# # #     RestClient.get "http://karinamio.com"
# # #   end
# # # end
# # #
# # # threads.each do |thread|
# # #   puts thread.value
# # # end
# # # binding.pry
# # # hydra = Typhoeus::Hydra.new
# # # requests = 500.times.map {
# # #   request = Typhoeus::Request.new("http://karinamio.com", followlocation: true)
# # #   hydra.queue(request)
# # #   request
# # # }
# # # hydra.run
# # #
# # # responses = requests.map { |request|
# # #   request.response.body
# # # }
# # # binding.pry
# #
# # # thread = []
# # # 500.times do |x|
# # #   Unirest.timeout(5)
# # #   t = Unirest.get "http://www.applebeescanada.com/", headers: {"User-Agent"=>"hello"} do |response|
# # #     response.body
# # #   end
# # #   thread << t
# # # end
# # # thread.each do |t|
# # #   puts "Hello"
# # #   begin
# # #     t.value
# # #   rescue
# # #     binding.pry
# # #     retry
# # #   end
# # # end
# # # binding.pry
# #
# # #
# # # list = []
# # # 100.times do |x|
# # #   if x%100 ==0 && x>0
# # #     sleep(3)
# # #   end
# # #
# # #   if running_thread_count > 10
# # #     sleep(1)
# # #   end
# # #
# # #   list << Thread.new do
# # #     RestClient.get "http://karinamio.com/", headers: {"User-Agent"=>"hello"}
# # #   end
# # # end
# # #
# # # i =0
# # # list.each do |t|
# # #   puts t.value
# # #   puts i
# # #   i +=1
# # # end
# # #
# #
# #
# # #im in main
# # #main variable
# #
# # # results = []
# # # EventMachine.run do
# # #   500.times do |response|
# # #     results << EventMachine::HttpRequest.new('http://123.com/').get
# # #     results[response].callback{puts self.reponse}
# # #   end
# # # end
# # # EventMachine.stop
# # # binding.pry
# # # EventMachine.run do
# # #   multi = EventMachine::MultiRequest.new
# # #   500.times do |x|
# # #     multi.add x.to_s.to_sym, EventMachine::HttpRequest.new('http://info.cern.ch/').get
# # #   end
# # #
# # #   multi.callback do
# # #     puts multi.responses[:callback]
# # #     puts multi.responses[:errback]
# # #     binding.pry
# # #     EventMachine.stop
# # #   end
# # # end
# # #
# # # mutex = Mutex.new
# # #
# # # i=0
# # # jon = []
# # # 50.times do
# # #   jon << Thread.new{
# # #       n = mutex.synchronize{i += 1}
# # #       print "#{n.to_s}\n"
# # #     }
# # # end
# # #
# # # jon.each do |j|
# # #   j.join
# # # end
# #
# # # require 'thread'
# # # mutex = Mutex.new
# # #
# # # count1 = count2 = 0
# # # difference = 0
# # # counter = Thread.new do
# # #    loop do
# # #       mutex.synchronize do
# # #          count1 += 1
# # #          count2 += 1
# # #       end
# # #     end
# # # end
# # # spy = Thread.new do
# # #    loop do
# # #        mutex.synchronize do
# # #           difference += (count1 - count2).abs
# # #        end
# # #    end
# # # end
# # # sleep 1
# # # mutex.lock
# # # puts "count1 :  #{count1}"
# # # puts "count2 :  #{count2}"
# # # puts "difference : #{difference}"
