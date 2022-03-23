require "socket"

server = TCPServer.new(1234)
loop do
  client = server.accept

  until (line = client.gets.chomp).empty?
    puts line
  end
  puts

  client.print <<~EOM
    HTTP/1.0 200 OK
    content-type: text/plain

    hello
  EOM
  client.close
end
