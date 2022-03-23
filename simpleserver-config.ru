require "socket"

class App
  def call(env)
    [
      200,
      {'Content-Type' => 'text/plain'},
      ['hello'],
    ]
  end
end

class SimpleServer
  def self.run(app, **options)
    new(app, options).start
  end

  def initialize(app, options)
    @app = app
    @options = options
    @server = TCPServer.new(options[:Port].to_i)

    loop do
      client = @server.accept
      unless %r[^GET (?<path>.+) HTTP/1.1$].match(client.gets.chomp)
        client.puts "HTTP/1.0 501 Not Implemented"
        client.close
        next
      end
      path = Regexp.last_match(:path)

      headers = Rack::Utils::HeaderHash.new
      while %r[^(?<name>[^:]+):\s+(?<value>.+)$].match(client.gets.chomp)
        headers[Regexp.last_match(:name)] = Regexp.last_match(:value)
      end

      env = ENV.to_hash.merge(
        Rack::REQUEST_METHOD    => "GET",
        Rack::SCRIPT_NAME       => "",
        Rack::PATH_INFO         => path,
        Rack::SERVER_NAME       => @options[:Host],
        Rack::RACK_VERSION      => Rack::VERSION,
        Rack::RACK_INPUT        => Rack::RewindableInput.new(client),
        Rack::RACK_ERRORS       => $stderr,
        Rack::QUERY_STRING      => "",
        Rack::REQUEST_PATH      => path,
        Rack::RACK_MULTITHREAD  => false,
        Rack::RACK_MULTIPROCESS => false,
        Rack::RACK_RUNONCE      => false,
        Rack::RACK_URL_SCHEME   => "http"
      )
      status, headers, body = app.call(env)
      client.puts "HTTP/1.0 #{status} OK"
      headers.each do |name, value|
        client.puts "#{name}: #{value}"
      end
      client.puts
      body.each do |line|
        client.puts line
      end
      client.close
    end
  end
end

Rack::Handler.register "simple_server", SimpleServer

run App.new
