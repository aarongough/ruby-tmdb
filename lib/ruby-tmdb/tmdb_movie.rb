class TmdbMovie
  
  def self.find(options)
    options = {
      :expand_results => true
    }.merge(options)
    
    raise ArgumentError, "At least one of: id, title, imdb should be supplied" if(options[:id].nil? && options[:title].nil? && options[:imdb].nil?)
    
    results = []
    unless(options[:id].nil? || options[:id].to_s.empty?)
      results << Tmdb.api_call("movie", {id: options[:id].to_s}, options[:language])
    end
    unless(options[:title].nil? || options[:title].to_s.empty?)
      api_return = Tmdb.api_call("search/movie", {query: options[:title].to_s}, options[:language])
      results << api_return["results"] if api_return
    end
    unless(options[:imdb].nil? || options[:imdb].to_s.empty?)
      results << Tmdb.api_call("movie", {id: options[:imdb].to_s}, options[:language])
      options[:expand_results] = true
    end
    
    results.flatten!(1)
    results.uniq!
    results.delete_if &:nil?
    
    unless(options[:limit].nil?)
      raise ArgumentError, ":limit must be an integer greater than 0" unless(options[:limit].is_a?(Fixnum) && options[:limit] > 0)
      results = results.slice(0, options[:limit])
    end
    
    results.map!{|m| TmdbMovie.new(m, options[:expand_results], options[:language])}
    
    if(results.length == 1)
      return results.first
    else
      return results
    end
  end
  
  def self.new(raw_data, expand_results = false, language = nil)
    # expand the result by calling movie unless :expand_results is false or the data is already complete
    # (as determined by checking for the runtime property in the raw data)
    if(expand_results && !raw_data.has_key?("runtime"))
      begin
        expanded_data = Tmdb.api_call("movie", {id: raw_data["id"].to_s}, language)
      rescue RuntimeError => e
        raise ArgumentError, "Unable to fetch expanded info for Movie ID: '#{raw_data["id"]}'" if expanded_data.nil?
      end
      raw_data = expanded_data
    end
    return Tmdb.data_to_object(raw_data)
  end
  
  def ==(other)
    return false unless(other.is_a?(TmdbMovie))
    return @raw_data == other.raw_data
  end
    
end