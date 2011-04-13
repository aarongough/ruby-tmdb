class TmdbMovie
  
  def self.find(options)
    options = {
      :expand_results => true
    }.merge(options)
    
    raise ArgumentError, "At least one of: id, title, imdb should be supplied" if(options[:id].nil? && options[:imdb].nil? && options[:title].nil?)
    
    results = []
    unless(options[:id].nil? || options[:id].to_s.empty?)
      results << Tmdb.api_call("Movie.getInfo", options[:id], options[:language])
    end
    unless(options[:imdb].nil? || options[:imdb].to_s.empty?)
      results << Tmdb.api_call("Movie.imdbLookup", options[:imdb], options[:language])
      options[:expand_results] = true
    end
    unless(options[:title].nil? || options[:title].to_s.empty?)
      results << Tmdb.api_call("Movie.search", options[:title], options[:language])
    end
    
    results.flatten!
    results.compact!
    
    unless(options[:limit].nil?)
      raise ArgumentError, ":limit must be an integer greater than 0" unless(options[:limit].is_a?(Fixnum) && options[:limit] > 0)
      results = results.slice(0, options[:limit])
    end
    
    results.map!{|m| TmdbMovie.new(m, options[:expand_results], options[:language]) }
    
    if(results.length == 1)
      return results[0]
    else
      return results
    end
  end
  
  def self.browse(options)
    options = {
      :expand_results => false
    }.merge(options)
    
    expand_results = options.delete(:expand_results)
    language = options.delete(:language)
    
    results = []
    results << Tmdb.api_call("Movie.browse", options, language)
    
    results.flatten!
    results.compact!
    
    results.map!{|m| TmdbMovie.new(m, expand_results, language) }
    
    if(results.length == 1)
      return results[0]
    else
      return results
    end
    
  end
  
  def self.new(raw_data, expand_results = false, language = nil)
    # expand the result by calling Movie.getInfo unless :expand_results is false or the data is already complete
    # (as determined by checking for the trailer property in the raw data)
    if(expand_results && !raw_data.has_key?("trailer"))
      expanded_data = Tmdb.api_call('Movie.getInfo', raw_data["id"], language)
      raise ArgumentError, "Unable to fetch expanded info for Movie ID: '#{raw_data["id"]}'" if expanded_data.nil?
      raw_data = expanded_data.first
    end
    return Tmdb.data_to_object(raw_data)
  end
  
  def ==(other)
    return false unless(other.is_a?(TmdbMovie))
    return @raw_data == other.raw_data
  end
    
end