def register_api_url_stubs  
  unless(TEST_LIVE_API)
  
    File.open(File.join(File.dirname(__FILE__), "..", "fixtures", "movie_search.txt")) do |file|
      stub_request(:get, Regexp.new(Tmdb.base_api_url + "Movie.search/" + ".*")).to_return(file)
    end
    
    File.open(File.join(File.dirname(__FILE__), "..", "fixtures", "movie_get_info.txt")) do |file|
      stub_request(:get, Regexp.new(Tmdb.base_api_url + "Movie.getInfo/" + ".*")).to_return(file)
    end
    
    File.open(File.join(File.dirname(__FILE__), "..", "fixtures", "movie_imdb_lookup.txt")) do |file|
      stub_request(:get, Regexp.new(Tmdb.base_api_url + "Movie.imdbLookup/" + ".*")).to_return(file)
    end
    
    File.open(File.join(File.dirname(__FILE__), "..", "fixtures", "movie_browse.txt")) do |file|
      stub_request(:get, Regexp.new(Tmdb.base_api_url + "Movie.browse/" + ".*")).to_return(file)
    end
    
    File.open(File.join(File.dirname(__FILE__), "..", "fixtures", "person_get_info.txt")) do |file|
      stub_request(:get, Regexp.new(Tmdb.base_api_url + "Person.getInfo/" + ".*")).to_return(file)
    end
    
    File.open(File.join(File.dirname(__FILE__), "..", "fixtures", "person_search.txt")) do |file|
      stub_request(:get, Regexp.new(Tmdb.base_api_url + "Person.search/" + ".*")).to_return(file)
    end
    
    File.open(File.join(File.dirname(__FILE__), "..", "fixtures", "incorrect_api_url.txt")) do |file|
      stub_request(:get, Regexp.new(Tmdb.base_api_url + "Movie.blarg/" + ".*")).to_return(file)
    end
      
    File.open(File.join(File.dirname(__FILE__), "..", "fixtures", "blank_result.txt")) do |file|
      stub_request(:get, Regexp.new(Tmdb.base_api_url + "Search.empty/" + ".*")).to_return(file)
    end
    
    File.open(File.join(File.dirname(__FILE__), "..", "fixtures", "example_com.txt")) do |file|
      stub_request(:get, Regexp.new("http://example.com.*")).to_return(file)
    end
    
    File.open(File.join(File.dirname(__FILE__), "..", "fixtures", "image.jpg")) do |file|
      stub_request(:get, Regexp.new('http://i[0-9].themoviedb.org/[backdrops|posters|profiles].*')).to_return(file)
    end
    
    File.open(File.join(File.dirname(__FILE__), "..", "fixtures", "image.jpg")) do |file|
      stub_request(:get, Regexp.new('http://hwcdn.themoviedb.org/[backdrops|posters|profiles].*')).to_return(file)
    end
    
    File.open(File.join(File.dirname(__FILE__), "..", "fixtures", "blank_result.txt")) do |file|
      stub_request(:get, Regexp.new("item_not_found$")).to_return(file)
    end
    
    stub_request(:get, 'http://thisisaurlthatdoesntexist.co.nz').to_return(:body => "", :status => 404, :headers => {'content-length' => 0})
  end
end