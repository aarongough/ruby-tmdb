require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class TmdbTest < Test::Unit::TestCase

  def setup
    register_api_url_stubs
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
    Tmdb.default_language = old_language
  end
  
  test "should return base API url" do
    assert_equal "http://api.themoviedb.org/2.1/", Tmdb.base_api_url
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
    method = "Movie.getInfo"
    data = "hello"
    Tmdb.default_language = "es"
    url = Tmdb.base_api_url + method + '/' + Tmdb.default_language + '/json/' + Tmdb.api_key + '/' + CGI::escape(data.to_s)
    mock_response = stub(:code => "200", :body => '[""]')
    Tmdb.expects(:get_url).with(url).returns(mock_response)
    Tmdb.api_call(method, data)
    Tmdb.default_language = "en"
  end
  
  test "API call with explicit language setting should override default language" do
    method = "Movie.getInfo"
    data = "hello"
    language = "blah"
    url = Tmdb.base_api_url + method + '/' + language + '/json/' + Tmdb.api_key + '/' + CGI::escape(data.to_s)
    mock_response = stub(:code => "200", :body => '[""]')
    Tmdb.expects(:get_url).with(url).returns(mock_response)
    Tmdb.api_call(method, data, language)
  end
  
  test "api_call should raise exception if api_key is not set" do
    old_api_key = Tmdb.api_key
    Tmdb.api_key = ""
    assert_raises ArgumentError do
      Tmdb.api_call('Movie.search', 'Transformers')
    end
    Tmdb.api_key = old_api_key
  end
  
  test "should perform Movie.search API call and return array of results" do
    movies = Tmdb.api_call('Movie.search', 'Transformers')
    assert_kind_of Array, movies
    assert movies.length > 1
    movies.each do |movie|
      assert_kind_of Hash, movie
      ["url", "id", "name"].each do |item|
        assert movie[item]
      end
    end
  end
  
  test "should perform Movie.getInfo API call and return array of results" do
    movies = Tmdb.api_call('Movie.getInfo', 187)
    assert_kind_of Array, movies
    assert movies.length == 1
    movies.each do |movie|
      assert_kind_of Hash, movie
      ["url", "id", "name"].each do |item|
        assert movie[item]
      end
    end
  end
  
  test "should perform Movie.imdbLookup API call and return array of results" do
    movies = Tmdb.api_call('Movie.imdbLookup', "tt0401792")
    assert_kind_of Array, movies
    assert movies.length == 1
    movies.each do |movie|
      assert_kind_of Hash, movie
      ["url", "id", "name"].each do |item|
        assert movie[item]
      end
    end
  end
  
  test "should perform Person.getInfo API call and return array of results" do
    people = Tmdb.api_call('Person.getInfo', 287)
    assert_kind_of Array, people
    assert people.length == 1
    people.each do |person|
      assert_kind_of Hash, person
      ["url", "id", "name"].each do |item|
        assert person[item]
      end
    end
  end
  
  test "should perform Person.search API call and return array of results" do
    people = Tmdb.api_call('Person.search', "vince")
    assert_kind_of Array, people
    assert people.length > 1
    people.each do |person|
      assert_kind_of Hash, person
      ["url", "id", "name"].each do |item|
        assert person[item]
      end
    end
  end
  
  test "API call that returns 404 should raise exception" do
    assert_raise RuntimeError do
      movies = Tmdb.api_call('Movie.blarg', 'Transformers')
    end
  end
  
  test "API call that finds no results should return nil" do
    movies = Tmdb.api_call('Search.empty', 'Transformers')
    assert_nil movies
  end
  
  test "API call cache should not be changed when data altered in the receiving method" do
    person = Tmdb.api_call('Person.getInfo', 287)[0]
    assert_not_nil person[person.keys[0]]
    person[person.keys[0]] = nil
    person = Tmdb.api_call('Person.getInfo', 287)[0]
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