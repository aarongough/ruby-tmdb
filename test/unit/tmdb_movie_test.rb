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
    movie = TmdbMovie.find(:title => "Sin City", :limit => 1, :expand_results => true)
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
    Tmdb.expects(:api_call).with("movie", {id: "1"}, nil).twice
    Tmdb.expects(:api_call).with("search/movie", {query: "1"}, nil)
    TmdbMovie.find(:id => 1, :imdb => 1, :title => 1)
  end
  
  test "find should pass through language to Tmdb.api_call when language is supplied" do
    Tmdb.expects(:api_call).with("movie", {id: "1"}, "foo").twice
    Tmdb.expects(:api_call).with("search/movie", {query: "1"}, "foo")
    TmdbMovie.find(:id => 1, :imdb => 1, :title => 1, :language => "foo")
  end
  
  test "TmdbMovie.new should raise error if supplied with raw data for movie that doesn't exist" do
    Tmdb.expects(:api_call).with("movie", {id: "999999999999"}, nil).returns(nil)
    assert_raise ArgumentError do
      TmdbMovie.new({"id" => 999999999999}, true)
    end
  end

  private
    
    def assert_movie_methodized(movie, movie_id)
      @movie_data = Tmdb.api_call("movie", {id: movie_id.to_s})
      assert_equal @movie_data["adult"], movie.adult
      assert_equal @movie_data["budget"], movie.budget
      assert_equal @movie_data["homepage"], movie.homepage
      assert_equal @movie_data["id"], movie.id
      assert_equal @movie_data["imdb_id"], movie.imdb_id
      assert_equal @movie_data["original_title"], movie.original_title
      assert_equal @movie_data["overview"], movie.overview
      assert_equal @movie_data["popularity"], movie.popularity
      assert_equal @movie_data["poster_path"], movie.poster_path
      assert_equal @movie_data["release_date"], movie.release_date
      assert_equal @movie_data["revenue"], movie.revenue
      assert_equal @movie_data["runtime"], movie.runtime
      assert_equal @movie_data["tagline"], movie.tagline
      assert_equal @movie_data["title"], movie.title
      assert_equal @movie_data["vote_average"], movie.vote_average
      assert_equal @movie_data["vote_count"], movie.vote_count

      assert_equal @movie_data["belongs_to_collection"]["id"], movie.belongs_to_collection.id
      assert_equal @movie_data["belongs_to_collection"]["name"], movie.belongs_to_collection.name
      assert_equal @movie_data["belongs_to_collection"]["poster_path"], movie.belongs_to_collection.poster_path
      assert_equal @movie_data["belongs_to_collection"]["backdrop_path"], movie.belongs_to_collection.backdrop_path

      @movie_data["genres"].each_index do |x|
        assert_equal @movie_data["genres"][x]["id"], movie.genres[x].id
        assert_equal @movie_data["genres"][x]["name"], movie.genres[x].name
      end
      @movie_data["production_companies"].each_index do |x|
        assert_equal @movie_data["production_companies"][x]["name"], movie.production_companies[x].name
        assert_equal @movie_data["production_companies"][x]["id"], movie.production_companies[x].id
      end
      @movie_data["production_countries"].each_index do |x|
        assert_equal @movie_data["production_countries"][x]["iso_3166_1"], movie.production_countries[x].iso_3166_1
        assert_equal @movie_data["production_countries"][x]["name"], movie.production_countries[x].name
      end
      @movie_data["spoken_languages"].each_index do |x|
        assert_equal @movie_data["spoken_languages"][x]["iso_639_1"], movie.spoken_languages[x].iso_639_1
        assert_equal @movie_data["spoken_languages"][x]["name"], movie.spoken_languages[x].name
      end
    end

end