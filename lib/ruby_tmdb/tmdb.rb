class Tmdb
  
  require 'singleton'
  require 'net/http'
  require 'uri'
  require 'cgi'
  
  include Singleton
  
  @@api_key = ""
  @@api_response = {}
  
  def self.api_key
    @@api_key
  end
  
  def self.api_key=(key)
    @@api_key = key
  end
  
  def self.base_api_url
    "http://api.themoviedb.org/2.1/"
  end
  
  def self.api_call(method, data, language = "en")
    url = Tmdb.base_api_url + method + '/' + language + '/yaml/' + Tmdb.api_key + '/' + CGI::escape(data.to_s)
    @@api_response[url] ||= begin
      response = Tmdb.get_url(url)
      if(response.code.to_i != 200)
        return []
      end
      YAML::load(response.body)
    end
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