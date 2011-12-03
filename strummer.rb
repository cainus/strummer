require 'json'
require 'sinatra/base'


class Strummer < Sinatra::Base
  set :views, File.join(File.dirname(__FILE__), '/views')

  get '/api/problem_frequency' do
    @problems = []
    n = params["limit"].to_i
    n.times do |i|
      @problems << {:level =>'fatal', :message => 'this is the message',
                    :last_occurance => DateTime.now.rfc3339,
                    :occurence_count =>rand(1000)}
    end
    response = {:problems => @problems}.to_json

    [200, {"Content-Type" => "application/json"}, response]
  end

end
