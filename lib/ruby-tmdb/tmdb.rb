class Tmdb
  
  require 'net/http'
  require 'uri'
  require 'cgi'
  require 'json'
  require 'deepopenstruct'
  
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
    raise ArgumentError, "Tmdb.api_key must be set before using the API" if(Tmdb.api_key.nil? || Tmdb.api_key.empty?)
    url = Tmdb.base_api_url + method + '/' + language + '/json/' + Tmdb.api_key + '/' + CGI::escape(data.to_s)
    response = Tmdb.get_url(url)
    if(response.code.to_i != 200)
      return []
    end
    body = JSON(response.body)
    if( body.first.include?("Nothing found"))
      return []
    else
      return body
    end
  end

  # Get a URL and return a response object, follow upto 'limit' re-directs on the way
  def self.get_url(uri_str, limit = 10)
    return false if limit == 0
    begin 
      response = Net::HTTP.get_response(URI.parse(uri_str))
    rescue SocketError, Errno::ENETDOWN
      response = Net::HTTPBadRequest.new( '404', 404, "Not Found" )
      return response
    end 
    case response
      when Net::HTTPSuccess     then response
      when Net::HTTPRedirection then get_url(response['location'], limit - 1)
    else
      Net::HTTPBadRequest.new( '404', 404, "Not Found" )
    end
  end
  
  def self.data_to_object(data)
    object = DeepOpenStruct.load(data)
    object.raw_data = data
    ["posters", "backdrops", "profile"].each do |image_array_name|
      if(object.respond_to?(image_array_name))
        image_array = object.send(image_array_name)
        image_array.each_index do |x|
          image_array[x] = image_array[x].image
          image_array[x].instance_eval <<-EOD
            def self.data
              return Tmdb.get_url(self.url).body
            end
          EOD
        end
      end
      if(object.profile)
        object.profiles = object.profile
      end
    end
    unless(object.cast.nil?)
      object.cast.each_index do |x|
        object.cast[x].instance_eval <<-EOD
          def self.bio
            return TmdbCast.find(:id => self.id, :limit => 1)
          end
        EOD
      end
    end
    return object
  end
  
end