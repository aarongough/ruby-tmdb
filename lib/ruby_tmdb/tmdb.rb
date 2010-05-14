class Tmdb
  
  require 'singleton'
  require 'net/http'
  require 'uri'
  
  include Singleton
  
  @@api_key = ""
  
  def self.api_key
    @@api_key
  end
  
  def self.api_key=(key)
    @@api_key = key
  end

  # Get a URL and return a response object, follow upto 'limit' re-directs on the way
  def self.get_url(uri_str, limit = 10)
    return false if limit == 0
    begin 
      response = Net::HTTP.get_response(URI.parse(uri_str))
    rescue
      raise
      response = Net::HTTPBadRequest.new( '404', 404, "Not Found" )
      return response
    end 
    case response
      when Net::HTTPSuccess     then response
      when Net::HTTPRedirection then get_url(response['location'], limit - 1)
    else
      response
    end
  end
  
end