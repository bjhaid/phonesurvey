require "tropo-webapi-ruby"

class TropoApp < Sinatra::Base

  enable :sessions

  get '/index.json' do
    "Welcome to PhoneSurvey"
  end

end
