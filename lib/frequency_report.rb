require 'mongo'

class FrequencyReport


  def test

    @db = Mongo::Connection.new("127.0.0.1", "27017").db('cotweet_dev')
    cursor = @db.collection("development_log").find({"$or" => [{'messages.fatal' => {"$exists" => true}}, {'messages.error' => {"$exists" => true}}]})
    cursor.each do |doc|
      if doc["messages"]["error"]
        doc["messages"]["error"].each do |message|
          @db.collection("test").insert({:message => message, :last_occurrence => doc["request_time"]})
        end
      end
    end
  end


end