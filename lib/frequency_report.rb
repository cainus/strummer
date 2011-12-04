require 'mongo'

class FrequencyReport


  def test

    @db = Mongo::Connection.new("127.0.0.1", "27017").db('cotweet_dev')
    @db.collection("development_log").find()
  end


end