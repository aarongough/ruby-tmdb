class TmdbMovie
  
  def self.find(options)
    raise ArgumentError, "At least one of: id, title, imdb should be supplied" if(options[:id].nil? && options[:imdb].nil? && options[:title].nil?)
    
    results = []
    unless(options[:id].nil? || options[:id].to_s.empty?)
      results << Tmdb.api_call("Movie.getInfo", options[:id])
    end
    unless(options[:imdb].nil? || options[:imdb].to_s.empty?)
      results << Tmdb.api_call("Movie.imdbLookup", options[:imdb])
    end
    unless(options[:title].nil? || options[:title].to_s.empty?)
      results << Tmdb.api_call("Movie.search", options[:title])
    end
    
    results.flatten!
    
    unless(options[:limit].nil?)
      raise ArgumentError, ":limit must be an integer greater than 0" unless(options[:limit].is_a?(Fixnum) && options[:limit] > 0)
      results = results.slice(0, options[:limit])
    end
    
    results.map!{|m| TmdbMovie.new(m) }
    
    if(results.length == 1)
      return results[0]
    else
      return results
    end
  end
  
  def initialize(raw_data)
    @raw_data = raw_data.dup
    @raw_data["credits"] = @raw_data["cast"]
    @raw_data.delete("cast")
    @raw_data.each_pair do |key, value|
      instance_eval <<-EOD
        def #{key}
          @raw_data["#{key}"]
        end
      EOD
      if(value.is_a?(Array))
        value.each_index do |x|
          if(value[x].is_a?(Hash) && value[x].length == 1)
            value[x] = value[x][value[x].keys[0]]
          end
          if(value[x].is_a?(Hash))
            value[x].each_pair do |key2, value2|
              value[x].instance_eval <<-EOD
                def self.#{key2}
                  self["#{key2}"]
                end
              EOD
            end
          end
        end
      end
    end
  end
    
end