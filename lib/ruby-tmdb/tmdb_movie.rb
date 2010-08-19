class TmdbMovie
  
  def self.find(options)
    options = {
      :expand_results => false
    }.merge(options)
    
    raise ArgumentError, "At least one of: id, title, imdb should be supplied" if(options[:id].nil? && options[:imdb].nil? && options[:title].nil?)
    
    results = []
    unless(options[:id].nil? || options[:id].to_s.empty?)
      results << Tmdb.api_call("Movie.getInfo", options[:id])
    end
    unless(options[:imdb].nil? || options[:imdb].to_s.empty?)
      results << Tmdb.api_call("Movie.imdbLookup", options[:imdb])
      options[:expand_results] = true
    end
    unless(options[:title].nil? || options[:title].to_s.empty?)
      results << Tmdb.api_call("Movie.search", options[:title])
    end
    
    results.flatten!
    
    unless(options[:limit].nil?)
      raise ArgumentError, ":limit must be an integer greater than 0" unless(options[:limit].is_a?(Fixnum) && options[:limit] > 0)
      results = results.slice(0, options[:limit])
    end
    
    results.map!{|m| TmdbMovie.new(m, options[:expand_results]) }
    
    if(results.length == 1)
      return results[0]
    else
      return results
    end
  end
  
  def self.new(raw_data, expand_results = false)
    raw_data = Tmdb.api_call('Movie.getInfo', raw_data["id"]).first if(expand_results)
    return Tmdb.data_to_object(raw_data)
  end
  
  def ==(other)
    return false unless(other.is_a?(TmdbMovie))
    return @raw_data == other.raw_data
  end
    
end