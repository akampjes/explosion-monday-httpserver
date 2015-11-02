require 'socket'

server = TCPServer.new(8080)

class HTTPRequest
  attr_reader :type, :filename, :protocol

  def initialize(request)
    @type, @filename, @protocol = request.split

    # TODO: sanitise and validate filename
    @filename = @filename.gsub(/\A\//, '')
  end
end

loop do
  client = server.accept
  request = client.gets

  # GET /testfile.txt HTTP/1.0
  http_request = HTTPRequest.new(request)
  if(File.exist?(http_request.filename))
    client.print "HTTP/1.0 200 OK\r\n"

    client.print "Content-Type: text/plain\r\n"
    client.print "\r\n"

    # TODO: read binary file?
    file =  File.open(http_request.filename, 'r')
    output = file.read

    client.print output
  else
    client.puts "HTTP/1.0 404 Not Found\r\n"
    client.print "\r\n"
  end

  client.close

  puts request
end

