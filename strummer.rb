require 'json'
require 'sinatra/base'


class Strummer < Sinatra::Base
  set :views, File.join(File.dirname(__FILE__), '/views')

  get '/api/problem_frequency' do
    @problems = []
    limit = 5
    if !!params["limit"]
      limit = params["limit"].to_i
    end
    limit.times do |i|
      @problems << {:level =>'fatal', :message => 'this is the message',
                    :last_occurrence => DateTime.now.rfc3339,
                    :occurrence_count =>rand(1000)}
    end
    response = {:problems => @problems}.to_json

    [200, {"Content-Type" => "application/json"}, response]
  end

  get '/' do
    redirect 'index.html'
  end

end
