require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class TmdbMovieTest < Test::Unit::TestCase

  def setup
    register_api_url_stubs
  end
  
  test "search that returns no results should create empty array" do
    movie = TmdbMovie.find(:title => "item_not_found")
    assert_equal [], movie
  end
  
  test "movie should be able to be dumped and re-loaded" do
    assert_nothing_raised do
      movie = TmdbMovie.find(:id => 187)
      TmdbMovie.new(movie.raw_data)
    end
  end
  
  test "find by id should return the full movie data" do
    movie = TmdbMovie.find(:id => 187)
    assert_movie_methodized(movie, 187)
  end
  
  test "movies with same data should be seen as equal" do
    movie1 = TmdbMovie.find(:id => 187, :limit => 1)
    movie2 = TmdbMovie.find(:id => 187, :limit => 1)
    assert_equal movie1, movie2
  end
  
  test "find by imdb should return the full movie data" do
    movie = TmdbMovie.find(:imdb => "tt0401792")
    assert_movie_methodized(movie, 187)
  end
  
  test "find by title should return the full movie data when expand_results set to true" do
    movie = TmdbMovie.find(:title => "Transformers: Revenge of the Fallen", :limit => 1, :expand_results => true)
    assert_movie_methodized(movie, 187)
  end
  
  test "should raise exception if no arguments supplied to find" do
    assert_raise ArgumentError do
      TmdbMovie.find()
    end
  end

  test "find by id should return a single movie" do
    assert_kind_of OpenStruct, TmdbMovie.find(:id => 187)
  end
  
  test "find by imdb should return a single movie" do
    assert_kind_of OpenStruct, TmdbMovie.find(:imdb => "tt0401792")
  end
  
  test "find by title should return an array of movies" do
    movies = TmdbMovie.find(:title => "Iron Man")
    assert_kind_of Array, movies
    movies.each do |movie|
      assert_kind_of OpenStruct, movie
    end
  end
    
  test "find by title with limit=1 should return a single movie" do
    assert_kind_of OpenStruct, TmdbMovie.find(:title => "Iron Man", :limit => 1)
  end
  
  test "find by title with limit=X should return an array of X movies" do
    (2..5).each do |x|
      movies = TmdbMovie.find(:title => "Iron Man", :limit => x)
      assert_kind_of Array, movies
      assert_equal x, movies.length
      movies.each do |movie|
        assert_kind_of OpenStruct, movie
      end
    end
  end
  
  test "should raise error if limit is smaller than 1" do
    [0, -1, -100].each do |limit|
      assert_raise ArgumentError do
        TmdbMovie.find(:title => "Iron Man", :limit => limit)
      end
    end
  end
  
  test "should raise error if limit is not an integer" do
    [1.001, "1.2", "hello", [1,2,3], {:test => "1"}].each do |limit|
      assert_raise ArgumentError do
        TmdbMovie.find(:title => "Iron Man", :limit => limit)
      end
    end
  end
  
  test "find should not pass language to Tmdb.api_call if language is not supplied" do
    Tmdb.expects(:api_call).with("Movie.getInfo", 1, nil).returns([])
    Tmdb.expects(:api_call).with("Movie.imdbLookup", 1, nil).returns([])
    Tmdb.expects(:api_call).with("Movie.search", 1, nil).returns([])
    TmdbMovie.find(:id => 1, :imdb => 1, :title => 1)
  end
  
  test "find should pass through language to Tmdb.api_call when language is supplied" do
    Tmdb.expects(:api_call).with("Movie.getInfo", 1, "foo").returns([])
    Tmdb.expects(:api_call).with("Movie.imdbLookup", 1, "foo").returns([])
    Tmdb.expects(:api_call).with("Movie.search", 1, "foo").returns([])
    TmdbMovie.find(:id => 1, :imdb => 1, :title => 1, :language => "foo")
  end
  
  test "TmdbMovie.new should raise error if supplied with raw data for movie that doesn't exist" do
    Tmdb.expects(:api_call).with('Movie.getInfo', "1").returns(nil)
    assert_raise ArgumentError do
      TmdbMovie.new({"id" => "1"}, true)
    end
  end

  test "browse should return results" do
    movies = TmdbMovie.browse(:order_by => "rating", :order => "desc", :genres => 18, :min_votes => 5, :page => 1, :per_page => 10)
    assert_kind_of Array, movies
    assert_equal 10, movies.length
    movies.each do |movie|
      assert_kind_of OpenStruct, movie
    end
  end
  
  test "browse should not pass language to Tmdb.api_call if language is not supplied" do
    Tmdb.expects(:api_call).with("Movie.browse", {:option => 1}, nil).returns([])
    TmdbMovie.browse(:option => 1)
  end
  
  test "browse should pass through language to Tmdb.api_call when language is supplied" do
    Tmdb.expects(:api_call).with("Movie.browse", {:option => 1}, "foo").returns([])
    TmdbMovie.browse(:option => 1, :language => "foo")
  end

  private
    
    def assert_movie_methodized(movie, movie_id)
      @movie_data = Tmdb.api_call('Movie.getInfo', movie_id)[0]
      assert_equal @movie_data["popularity"], movie.popularity
      assert_equal @movie_data["translated"], movie.translated
      assert_equal @movie_data["language"], movie.language
      assert_equal @movie_data["name"], movie.name
      assert_equal @movie_data["alternative_name"], movie.alternative_name
      assert_equal @movie_data["movie_type"], movie.movie_type
      assert_equal @movie_data["id"], movie.id
      assert_equal @movie_data["imdb_id"], movie.imdb_id
      assert_equal @movie_data["url"], movie.url
      assert_equal @movie_data["rating"], movie.rating
      assert_equal @movie_data["tagline"], movie.tagline
      assert_equal @movie_data["certification"], movie.certification
      assert_equal @movie_data["overview"], movie.overview
      assert_equal @movie_data["released"], movie.released
      assert_equal @movie_data["runtime"], movie.runtime
      assert_equal @movie_data["budget"], movie.budget
      assert_equal @movie_data["revenue"], movie.revenue
      assert_equal @movie_data["homepage"], movie.homepage
      assert_equal @movie_data["trailer"], movie.trailer
      assert_equal @movie_data["last_modified_at"], movie.last_modified_at
      @movie_data["genres"].each_index do |x|
        assert_equal @movie_data["genres"][x]["type"], movie.genres[x].type
        assert_equal @movie_data["genres"][x]["url"], movie.genres[x].url
        assert_equal @movie_data["genres"][x]["name"], movie.genres[x].name
      end
      @movie_data["studios"].each_index do |x|
        assert_equal @movie_data["studios"][x]["url"], movie.studios[x].url
        assert_equal @movie_data["studios"][x]["name"], movie.studios[x].name
      end
      @movie_data["countries"].each_index do |x|
        assert_equal @movie_data["countries"][x]["code"], movie.countries[x].code
        assert_equal @movie_data["countries"][x]["url"], movie.countries[x].url
        assert_equal @movie_data["countries"][x]["name"], movie.countries[x].name
      end
      @movie_data["posters"].each_index do |x|
        assert_equal @movie_data["posters"][x]["image"]["type"], movie.posters[x].type
        assert_equal @movie_data["posters"][x]["image"]["size"], movie.posters[x].size
        assert_equal @movie_data["posters"][x]["image"]["height"], movie.posters[x].height
        assert_equal @movie_data["posters"][x]["image"]["width"], movie.posters[x].width
        assert_equal @movie_data["posters"][x]["image"]["url"], movie.posters[x].url
        assert_equal @movie_data["posters"][x]["image"]["id"], movie.posters[x].id
        assert_equal Tmdb.get_url(@movie_data["posters"][x]["image"]["url"]).body, movie.posters[x].data
      end
      @movie_data["backdrops"].each_index do |x|
        assert_equal @movie_data["backdrops"][x]["image"]["type"], movie.backdrops[x].type
        assert_equal @movie_data["backdrops"][x]["image"]["size"], movie.backdrops[x].size
        assert_equal @movie_data["backdrops"][x]["image"]["height"], movie.backdrops[x].height
        assert_equal @movie_data["backdrops"][x]["image"]["width"], movie.backdrops[x].width
        assert_equal @movie_data["backdrops"][x]["image"]["url"], movie.backdrops[x].url
        assert_equal @movie_data["backdrops"][x]["image"]["id"], movie.backdrops[x].id
        assert_equal Tmdb.get_url(@movie_data["backdrops"][x]["image"]["url"]).body, movie.backdrops[x].data
      end
      @movie_data["cast"].each_index do |x|
        assert_equal @movie_data["cast"][x]["name"], movie.cast[x].name
        assert_equal @movie_data["cast"][x]["job"], movie.cast[x].job
        assert_equal @movie_data["cast"][x]["department"], movie.cast[x].department
        assert_equal @movie_data["cast"][x]["character"], movie.cast[x].character
        assert_equal @movie_data["cast"][x]["id"], movie.cast[x].id
        assert_equal @movie_data["cast"][x]["url"], movie.cast[x].url
        assert_equal @movie_data["cast"][x]["profile"], movie.cast[x].profile
        assert_equal TmdbCast.find(:id => @movie_data["cast"][x]["id"], :limit => 1), movie.cast[x].bio
      end
    end

end