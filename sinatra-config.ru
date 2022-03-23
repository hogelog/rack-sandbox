require "sinatra/base"

class App < Sinatra::Base
  get "*" do
    "hello"
  end
end

run App
