require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class TmdbCastTest < Test::Unit::TestCase

  def setup
    register_api_url_stubs
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
  
  test "find by name should return full cast data" do
    cast = TmdbCast.find(:name => "Brad Pitt").first
    assert_cast_methodized(cast, 287)
  end

  test "should raise exception if no arguments supplied to find" do
    assert_raise ArgumentError do
      TmdbCast.find()
    end
  end

  test "find by id should return a single cast member" do
    assert_kind_of TmdbCast, TmdbCast.find(:id => 287)
  end
  
  test "find by name should return an array of cast members" do
    cast_members = TmdbCast.find(:name => "vince")
    assert_kind_of Array, cast_members
    cast_members.each do |actor|
      assert_kind_of TmdbCast, actor
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
    assert_kind_of TmdbCast, actor
  end
  
  test "should return X items if limit=X" do
    (2..5).each do |x|
      actors = TmdbCast.find(:name => "Vince", :limit => x)
      assert_kind_of Array, actors
      assert_equal x, actors.length
      actors.each do |actor|
        assert_kind_of TmdbCast, actor
      end
    end
  end
  
  private
  
    def assert_cast_methodized(actor, cast_id)
      @cast_data = Tmdb.api_call('Person.getInfo', cast_id)[0]
      assert_equal @cast_data["popularity"], actor.popularity
      assert_equal @cast_data["name"], actor.name
      assert_equal @cast_data["known_as"], actor.known_as
      assert_equal @cast_data["id"], actor.id
      assert_equal @cast_data["biography"], actor.biography
      assert_equal @cast_data["known_movies"], actor.known_movies
      assert_equal @cast_data["birthday"], actor.birthday
      assert_equal @cast_data["birthplace"], actor.birthplace
      assert_equal @cast_data["url"], actor.url
      @cast_data["filmography"].each_index do |x|
        assert_equal @cast_data["filmography"][x]["name"], actor.filmography[x].name
        assert_equal @cast_data["filmography"][x]["id"], actor.filmography[x].id
        assert_equal @cast_data["filmography"][x]["job"], actor.filmography[x].job
        assert_equal @cast_data["filmography"][x]["department"], actor.filmography[x].department
        assert_equal @cast_data["filmography"][x]["character"], actor.filmography[x].character
        assert_equal @cast_data["filmography"][x]["url"], actor.filmography[x].url
      end
      @cast_data["profile"].each_index do |x|
        assert_equal @cast_data["profile"][x]["image"]["type"], actor.profiles[x].type
        assert_equal @cast_data["profile"][x]["image"]["size"], actor.profiles[x].size
        assert_equal @cast_data["profile"][x]["image"]["height"], actor.profiles[x].height
        assert_equal @cast_data["profile"][x]["image"]["width"], actor.profiles[x].width
        assert_equal @cast_data["profile"][x]["image"]["url"], actor.profiles[x].url
        assert_equal @cast_data["profile"][x]["image"]["id"], actor.profiles[x].id
        assert_equal Tmdb.get_url(@cast_data["profile"][x]["image"]["url"]).body, actor.profiles[x].data
      end
    end

end