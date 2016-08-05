require "unirest"
require "pry"
require "restclient"
# require "eventmachine"
require "em-http-request"
# thread = []
# 500.times do |x|
#   Unirest.timeout(5)
#   t = Unirest.get "http://www.applebeescanada.com/", headers: {"User-Agent"=>"hello"} do |response|
#     response.body
#   end
#   thread << t
# end
# thread.each do |t|
#   puts "Hello"
#   begin
#     t.value
#   rescue
#     binding.pry
#     retry
#   end
# end
# binding.pry
def running_thread_count
  Thread.list.select {|thread| thread.status == "run"}.count
end

list = []
100.times do |x|
  if x%100 ==0 && x>0
    sleep(3)
  end

  if running_thread_count > 10
    sleep(1)
  end

  list << Thread.new do
    RestClient.get "http://karinamio.com/", headers: {"User-Agent"=>"hello"}
  end
end

i =0
list.each do |t|
  puts t.value
  puts i
  i +=1
end



#im in main
#main variable

# results = []
# EventMachine.run do
#   500.times do |response|
#     results << EventMachine::HttpRequest.new('http://123.com/').get
#     results[response].callback{puts self.reponse}
#   end
# end
# EventMachine.stop
# binding.pry
# EventMachine.run do
#   multi = EventMachine::MultiRequest.new
#   500.times do |x|
#     multi.add x.to_s.to_sym, EventMachine::HttpRequest.new('http://info.cern.ch/').get
#   end
#
#   multi.callback do
#     puts multi.responses[:callback]
#     puts multi.responses[:errback]
#     binding.pry
#     EventMachine.stop
#   end
# end
