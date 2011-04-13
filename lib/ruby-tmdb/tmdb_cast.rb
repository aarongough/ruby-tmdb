class TmdbCast

  def self.find(options)
    options = {
      :expand_results => true
    }.merge(options)
  
    raise ArgumentError, "At least one of: id, name, should be supplied" if(options[:id].nil? && options[:name].nil?)
    
    results = []
    unless(options[:id].nil? || options[:id].to_s.empty?)
      results << Tmdb.api_call('Person.getInfo', options[:id], options[:language])
    end
    unless(options[:name].nil? || options[:name].to_s.empty?)
      results << Tmdb.api_call('Person.search', options[:name], options[:language])
    end
    
    results.flatten!
    results.compact!
    
    unless(options[:limit].nil?)
      raise ArgumentError, ":limit must be an integer greater than 0" unless(options[:limit].is_a?(Fixnum) && options[:limit] > 0)
      results = results.slice(0, options[:limit])
    end
  
    results.map!{|c| TmdbCast.new(c, options[:expand_results], options[:language]) }
  
    if(results.length == 1)
      return results[0]
    else
      return results
    end
  end
  
  def self.new(raw_data, expand_results = false, language = nil)
    # expand the result by calling Person.getInfo unless :expand_results is set to false or the data is already complete
    # (as determined by checking for the 'known_movies' property)
    if(expand_results && !raw_data.has_key?("known_movies"))
      expanded_data = Tmdb.api_call('Person.getInfo', raw_data["id"], language)
      raise ArgumentError, "Unable to fetch expanded info for Cast ID: '#{raw_data["id"]}'" if expanded_data.nil?
      raw_data = expanded_data.first
    end
    return Tmdb.data_to_object(raw_data)
  end
  
  def ==(other)
    return false unless(other.is_a?(TmdbCast))
    @raw_data == other.raw_data
  end
  
end