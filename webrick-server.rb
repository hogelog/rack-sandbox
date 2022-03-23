require "webrick"

server = WEBrick::HTTPServer.new(Port: 1234)
server.mount_proc("/") do |req, res|
  res.body = "hello"
end
server.start
