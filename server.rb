require 'sinatra'

class Server < Sinatra::Application

  get '/' do
    erb :index
  end

end