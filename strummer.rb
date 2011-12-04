require 'json'
require 'sinatra/base'
require "set"
require './lib/frequency_report'

  # Ruby implementation of the string similarity described by Simon White
  # at: http://www.catalysoft.com/articles/StrikeAMatch.html
  #
  # 2 * |pairs(s1) INTERSECT pairs(s2)|
  # similarity(s1, s2) = -----------------------------------
  # |pairs(s1)| + |pairs(s2)|
  #
  # e.g.
  # 2 * |{FR, NC}|
  # similarity(FRANCE, FRENCH) = ---------------------------------------
  # |{FR,RA,AN,NC,CE}| + |{FR,RE,EN,NC,CH}|
  #
  # = (2 * 2) / (5 + 5)
  #
  # = 0.4
  #
  # WhiteSimilarity.new.similarity("FRANCE", "FRENCH")
  #
  class WhiteSimilarity

    def self.similarity(str1, str2)
      new.similarity(str1, str2)
    end

    def initialize
      @word_letter_pairs = {}
    end

    def similarity(str1, str2)
      pairs1 = word_letter_pairs(str1)
      pairs2 = word_letter_pairs(str2)

      intersection = pairs1.inject(0) { |acc, pair|
        pairs2.include?(pair) ? acc + 1 : acc
      }
      union = pairs1.length + pairs2.length

      (2.0 * intersection) / union
    end

  private
    def word_letter_pairs(str)
      @word_letter_pairs[str] ||= Set.new(
        str.upcase.split(/\s+/).map{ |word|
          (0 ... (word.length - 1)).map { |i| str[i, 2] }
        }.flatten
      )
    end
  end




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


    mongo_errors = FrequencyReport.new.get_error_hashes
    errors = group_similar_errors(mongo_errors)
    puts errors.inspect
    top_errors = get_top_errors(group_similar_errors())
    puts top_errors.inspect

    [200, {"Content-Type" => "application/json"}, response]
  end

  get '/' do
    redirect 'index.html'
  end


  def get_top_errors(error_hashes, count=5)
    error_hashes = error_hashes.sort! {|x,y| y[:count] <=> x[:count] }
    error_hashes = error_hashes.slice!(0,count)
    return error_hashes
  end


  def group_similar_errors(error_hashes = nil)
    match_probability = 0.7
    
    if error_hashes.nil?
      # a list of error hashes looks like this:
      error_hashes = [
                        {:message => "this is the message from 4:00 pm", :last_occurrence => DateTime.now },
                        {:message => "this is the message from 4:01 pm", :last_occurrence => DateTime.now }, 
                        {:message => "completely different thing to say 4:01 pm", :last_occurrence => DateTime.now }, 
                        {:message => "completely different thing to say again", :last_occurrence => DateTime.now }, 
                        {:message => "WTF is going on?  this shit isd fucked!!!", :last_occurrence => DateTime.now }, 
                        {:message => "distinct error again. totally delta dude!!!", :last_occurrence => DateTime.now }
      ] 
    end

    white = WhiteSimilarity.new
    new_error_hashes = []
    error_hashes.each do |original_hash|
      found = false
      new_error_hashes.each do |new_hash|
        if white.similarity(new_hash[:message], original_hash[:message]) > match_probability
          new_hash[:count] += 1
          found = true
          break
        end
      end
      unless found
        original_hash[:count] = 1
        new_error_hashes << original_hash
      end
    end

    return new_error_hashes 
  end


end
