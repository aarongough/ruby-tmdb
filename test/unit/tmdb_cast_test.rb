require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class TmdbCastTest < Test::Unit::TestCase

  def setup
    register_api_url_stubs
  end

  test "search that returns no results should create empty array" do
    movie = TmdbCast.find(:name => "item_not_found")
    assert_equal [], movie
  end
  
  test "cast data should be able to be dumped and re-loaded" do
    assert_nothing_raised do
      cast = TmdbCast.find(:id => 287)
      TmdbCast.new(cast.raw_data)
    end
  end
  
  test "find by id should return full cast data" do
    cast = TmdbCast.find(:id => 287)
    assert_cast_methodized(cast, 287)
  end
  
  test "two cast objects with same data should be equal" do
    cast1 = TmdbCast.find(:id => 287, :limit => 1)
    cast2 = TmdbCast.find(:id => 287, :limit => 1)
    assert_equal cast1, cast2
  end
  
  test "find by name should return full cast data when :expand_results = true" do
    cast = TmdbCast.find(:name => "Brad Pitt", :expand_results => true)
    cast = cast.first if cast.class == Array
    assert_cast_methodized(cast, 287)
  end

  test "should raise exception if no arguments supplied to find" do
    assert_raise ArgumentError do
      TmdbCast.find()
    end
  end

  test "find by id should return a single cast member" do
    assert_kind_of OpenStruct, TmdbCast.find(:id => 287)
  end
  
  test "find by name should return an array of cast members" do
    cast_members = TmdbCast.find(:name => "vince")
    assert_kind_of Array, cast_members
    cast_members.each do |actor|
      assert_kind_of OpenStruct, actor
    end
  end
  
  test "should raise error if limit is smaller than 1" do
    [0, -1, -100].each do |limit|
      assert_raise ArgumentError do
        TmdbCast.find(:name => "vince", :limit => limit)
      end
    end
  end
  
  test "should raise error if limit is not an integer" do
    [1.001, "1.2", "hello", [1,2,3], {:test => "1"}].each do |limit|
      assert_raise ArgumentError do
        TmdbCast.find(:name => "vince", :limit => limit)
      end
    end
  end
  
  test "should only return a single item if limit=1" do
    actor = TmdbCast.find(:name => "Vince", :limit => 1)
    assert_kind_of OpenStruct, actor
  end
  
  test "should return X items if limit=X" do
    (2..5).each do |x|
      actors = TmdbCast.find(:name => "Vince", :limit => x)
      assert_kind_of Array, actors
      assert_equal x, actors.length
      actors.each do |actor|
        assert_kind_of OpenStruct, actor
      end
    end
  end

  test "should not pass language to Tmdb.api_call if language is not supplied" do
    Tmdb.expects(:api_call).with("person", {id: "1"}, nil).returns(nil)
    Tmdb.expects(:api_call).with("search/person", {query: "1"}, nil).returns(nil)
    TmdbCast.find(:id => 1, :name => 1)
  end

  test "should pass through language to Tmdb.api_call when language is supplied" do
    Tmdb.expects(:api_call).with("person", {id: "1"}, "foo").returns(nil)
    Tmdb.expects(:api_call).with("search/person", {query: "1"}, "foo").returns(nil)
    TmdbCast.find(:id => 1, :name => 1, :language => "foo")
  end

  test "TmdbCast.new should raise error if supplied with raw data for cast member that doesn't exist" do
    Tmdb.expects(:api_call).with("person", {id: "999999999999"}, nil).returns(nil)
    assert_raise ArgumentError do
      TmdbCast.new({"id" => 999999999999}, true)
    end
  end

  private
  
    def assert_cast_methodized(actor, cast_id)
      @cast_data = Tmdb.api_call("person", {id: cast_id.to_s})
      assert_equal @cast_data["adult"], actor.adult
      assert_equal @cast_data["also_known_as"], actor.also_known_as
      assert_equal @cast_data["biography"], actor.biography
      assert_equal @cast_data["birthday"], actor.birthday
      assert_equal @cast_data["biography"], actor.biography
      assert_equal @cast_data["deathday"], actor.deathday
      assert_equal @cast_data["homepage"], actor.homepage
      assert_equal @cast_data["id"], actor.id
      assert_equal @cast_data["name"], actor.name
      assert_equal @cast_data["place_of_birth"], actor.place_of_birth
      assert_equal @cast_data["profile_path"], actor.profile_path
    end

end