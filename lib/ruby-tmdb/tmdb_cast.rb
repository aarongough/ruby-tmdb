class TmdbCast

  def self.find(options)
    raise ArgumentError, "At least one of: id, name, should be supplied" if(options[:id].nil? && options[:name].nil?)
    
    results = []
    unless(options[:id].nil? || options[:id].to_s.empty?)
      results << Tmdb.api_call('Person.getInfo', options[:id])
    end
    unless(options[:name].nil? || options[:name].to_s.empty?)
      results << Tmdb.api_call('Person.search', options[:name])
    end
    
    results.flatten!
    
    unless(options[:limit].nil?)
      raise ArgumentError, ":limit must be an integer greater than 0" unless(options[:limit].is_a?(Fixnum) && options[:limit] > 0)
      results = results.slice(0, options[:limit])
    end
  
    results.map!{|c| TmdbCast.new(c) }
  
    if(results.length == 1)
      return results[0]
    else
      return results
    end
  end
  
  def initialize(raw_data)
    @raw_data = raw_data
    @raw_data = Tmdb.api_call('Person.getInfo', @raw_data["id"]).first
    @raw_data["profiles"] = @raw_data["profile"]
    @raw_data.delete("profile")
    @raw_data.each_pair do |key, value|
      instance_eval <<-EOD
        def #{key}
          @raw_data["#{key}"]
        end
      EOD
      if(value.is_a?(Array))
        value.each_index do |x|
          if(value[x].is_a?(Hash) && value[x].length == 1)
            if(value[x].keys[0] == "image")
              value[x][value[x].keys[0]].instance_eval <<-EOD
                def self.data
                  Tmdb.get_url(self["url"]).body
                end
              EOD
            end
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
  
  def raw_data
    @raw_data
  end
  
  def ==(other)
    return false unless(other.is_a?(TmdbCast))
    @raw_data == other.raw_data
  end
  
end