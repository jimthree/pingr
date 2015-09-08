require 'net/http'
require 'uri'
require 'mongo'



def ping(host)
begin
 logger = Mongo::Logger.logger.level = ::Logger::WARN # Set Mongo debugger level to only alert on WARN or higher
 client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'Ping') # Open a connection to a mongo DB
 url=URI.parse(host) # Read in the URL and parse it.
 start_time = Time.now # log the start time
 response=Net::HTTP.get(url) # GET the URL
 end_time = Time.now - start_time # Work out how long it took to do the Get
   if response=="" # If the response body is empty then ...
     result = client[:ping_time].insert_one({ name: "#{url}" },{ time: "unreachable" }) #enter into the db "unreachable" (may not be strictly true)
     return false
   else
     puts "response time : #{end_time} from #{url}" # send some output to the 
     result = client[:ping_time].insert_one({ts: "#{start_time}", time: "#{end_time}", host: "#{url}"}) #insert the result into the collection
	 result.n #=> returns 1, because 1 document was inserted.
     return true
   end
   rescue Errno::ECONNREFUSED
     return false
 end
end


def do_pings() # sequence the pings
	begin
		while 1
			puts("\n\n\n-------------------\n\n")
			ping "http://google.com" #URLs to Ping
			ping "http://jimb.cc"
			ping "http://amazon.co.uk"
			sleep(10) # Sleep for some seconds.
			
		end
	end
end

do_pings # start the ping sequence