require_relative 'frank'

get '/hello' do
  'Frank says hello!'
end

get '/goodbye' do
  'Frank says goodbye!'
end

get '/google' do
  [301, { 'Location' => 'https://www.google.com' }, []]
end

get '/' do
  ans = ["This is a Frank application, say /hello or /goodbye if you like!\n\n"]
  params.each { |parameter, value| ans << "Parameter #{parameter} is #{value}\n" }
  [200, {}, ans]
end

post '/' do
  [200, {}, request.body]
end

Rack::Handler::WEBrick.run Frank::Application, Port: 4000
