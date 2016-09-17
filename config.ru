require 'bundler'
Bundler.require(:default)
require 'json'
require 'sinatra/base'
require_relative './app/app_bot'
require_relative './app/models/offer'
require_relative './app/services/session_storage'

class Root < Sinatra::Base
  get '/' do
    STDERR.puts 'works'
    'It works!'
  end
  post '/' do
    request.body.rewind
    body = request.body.read
    puts "body: #{body}"
    payload = JSON.parse body
    STDERR.puts "payload: #{payload}"

    update = Telegrammer::DataTypes::Update.new(payload)

    AppBot
      .new(update)
      .perform

    'Ok'
  end
end

# use Root
run Root
