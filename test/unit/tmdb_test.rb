require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class TmdbTest < Test::Unit::TestCase

  def setup
    register_api_url_stubs
    @@old_default_language = Tmdb.default_language
  end

  def teardown
    Tmdb.default_language = @@old_default_language
  end

  test "should allow setting and getting of api_key" do
    old_api_key = Tmdb.api_key
    api_key = "test1234567890"
    Tmdb.api_key = api_key
    assert_equal Tmdb.api_key, api_key
    Tmdb.api_key = old_api_key
  end
  
  test "language should default to 'en'" do
    assert_equal "en", Tmdb.default_language
  end
  
  test "should allow setting and getting of language" do
    old_language = Tmdb.default_language
    new_language = "blah"
    Tmdb.default_language = new_language
    assert_equal new_language, Tmdb.default_language
  end
  
  test "should return base API url" do
    assert_equal "http://api.themoviedb.org/3/", Tmdb.base_api_url
  end

  test "get url returns a response object" do
    test_response = Tmdb.get_url("http://example.com/")
    assert_equal 200, test_response.code.to_i
  end
  
  test "getting nonexistent URL returns response object" do
    test_response = Tmdb.get_url('http://thisisaurlthatdoesntexist.co.nz')
    assert_equal 404, test_response.code.to_i
  end
  
  test "API call without explicit language setting should use default language" do
    method = "search/movie"
    data = "hello"
    Tmdb.default_language = "es"
    url = Tmdb.base_api_url + method + '?api_key=' + Tmdb.api_key + '&language=' + Tmdb.default_language + '&query=' + CGI::escape(data.to_s)
    mock_response = stub(:code => "200", :body => '{"page":1,"results":[],"total_pages":0,"total_results":0}')
    Tmdb.expects(:get_url).with(url).returns(mock_response)
    Tmdb.api_call(method, {query: data})
  end
  
  test "API call with explicit language setting should override default language" do
    method = "movie"
    data = "hello"
    language = "blah"
    url = Tmdb.base_api_url + method + "?api_key=" + Tmdb.api_key + "&language=" + language + '&query=' + CGI::escape(data.to_s)
    mock_response = stub(:code => "200", :body => '{"page":1,"results":[],"total_pages":0,"total_results":0}')
    Tmdb.expects(:get_url).with(url).returns(mock_response)
    Tmdb.api_call(method, {query: data}, language)
  end
  
  test "api_call should raise exception if api_key is not set" do
    old_api_key = Tmdb.api_key
    Tmdb.api_key = ""
    assert_raises ArgumentError do
      Tmdb.api_call('Movie.search', 'Transformers')
    end
    Tmdb.api_key = old_api_key
  end
  
  test "should perform search/movie API call and return a Hash with an array of results" do
    movies = Tmdb.api_call("search/movie", {query: "Transformers"})
    assert_kind_of Hash, movies
    assert_kind_of Array, movies["results"]
    movies["results"].each do |movie|
      assert_kind_of Hash, movie
      %w(original_title id).each do |item|
        assert movie[item]
      end
    end
  end
  
  test "should perform movie API call and return a single result" do
    result = Tmdb.api_call("movie", {id: "187"})
    assert_kind_of Hash, result
    %w(original_title id).each do |item|
      assert_not_nil result[item]
    end
  end
  
  test "should perform Movie.imdbLookup API call and return a single result" do
    result = Tmdb.api_call("movie", {id: "tt0401792"})
    assert_kind_of Hash, result
    %w(original_title id).each do |item|
      assert result[item]
    end
  end
  
  test "should perform person API call and return a single result" do
    result = Tmdb.api_call("person", {id: 287})
    assert_kind_of Hash, result
    %w(homepage id name).each do |item|
      assert_not_nil result[item]
    end
  end
  
  test "should perform search/person API call and return a Hash with an array of results" do
    people = Tmdb.api_call("search/person", {query: "vince"})
    assert_kind_of Array, people["results"]
    people["results"].each do |person|
      assert_kind_of Hash, person
      %w(id name).each do |item|
        assert_not_nil person[item]
      end
    end
  end
  
  test "API call that returns 404 should raise exception" do
    assert_raise ArgumentError do
      movies = Tmdb.api_call('Movie.blarg', 'Transformers')
    end
  end
  
  test "API call that finds no results should return nil" do
    movies = Tmdb.api_call('search/movie', {query: "item_not_found"})
    assert_nil movies
  end
  
  test "API call cache should not be changed when data altered in the receiving method" do
    person = Tmdb.api_call("person", {id: 287})
    assert_not_nil person[person.keys[0]]
    person[person.keys[0]] = nil
    person = Tmdb.api_call("person", {id: 287})
    assert_not_nil person[person.keys[0]]
  end
  
  test "data_to_object should create object from nested data structures" do
    test_data = {
      :test1 => [
        1,2,3,4
      ],
      :test2 => 1
    }
    test_object = Tmdb.data_to_object(test_data)
    assert_nothing_raised do
      assert_equal [1,2,3,4], test_object.test1
      assert_equal 1, test_object.test2
    end
  end
  
  test "data_to_object should include raw_data method that returns original data" do
    test_data = {
      :test1 => [1,2,3]
    }
    test_object = Tmdb.data_to_object(test_data)
    assert_equal test_object.raw_data, test_data
  end
  
  test "data_to_object should convert arrays containing images to nicer format" do
    test_data = {
      "backdrops" => [
        {
          "image" => {
            :test => 1
          }
        }
      ]
    }
    test_object = Tmdb.data_to_object(test_data)
    assert_nothing_raised do
      assert_equal 1, test_object.backdrops[0].test
    end
  end

end