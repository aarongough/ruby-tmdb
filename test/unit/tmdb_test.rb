require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class TmdbTest < Test::Unit::TestCase

  test "allows setting of api_key" do
    old_api_key = Tmdb.api_key
    api_key = "test1234567890"
    Tmdb.api_key = api_key
    assert_equal Tmdb.api_key, api_key
    Tmdb.api_key = old_api_key
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
  
  test "failed API call should return empty array" do
    movies = Tmdb.api_call('Movie.blarg', 'Transformers')
    assert_kind_of Array, movies
    assert movies.empty?
  end
  
  test "API call cache should not be changed when data altered in the receiving method" do
    person = Tmdb.api_call('Person.getInfo', 287)[0]
    assert_not_nil person[person.keys[0]]
    person[person.keys[0]] = nil
    person = Tmdb.api_call('Person.getInfo', 287)[0]
    assert_not_nil person[person.keys[0]]
  end

end