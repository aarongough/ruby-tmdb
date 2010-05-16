require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class TmdbCastTest < Test::Unit::TestCase

#  test "find by id and name should all return full cast data" do
#    @test_cast_members = []
#    @test_cast_members << TmdbCast.find(:id => 287)
#    @test_cast_members << TmdbCast.find(:name => "Brad Pitt").first
#    @cast_data = YAML::load(Tmdb.get_url("http://api.themoviedb.org/2.1/Person.getInfo/en/yaml/#{Tmdb.api_key}/287").body)[0]
#    @test_cast_members.each do |actor|
#      assert_equal @cast_data["popularity"], actor.popularity
#      assert_equal @cast_data["name"], actor.name
#      assert_equal @cast_data["known_as"], actor.known_as
#      assert_equal @cast_data["id"], actor.id
#      assert_equal @cast_data["biography"], actor.biography
#      assert_equal @cast_data["known_movies"], actor.known_movies
#      assert_equal @cast_data["birthday"], actor.birthday
#      assert_equal @cast_data["birthplace"], actor.birthplace
#      assert_equal @cast_data["url"], actor.url
#      @cast_data["filmography"].each_index do |x|
#        assert_equal @cast_data["filmography"][x]["name"], actor.filmography[x].name
#        assert_equal @cast_data["filmography"][x]["id"], actor.filmography[x].id
#        assert_equal @cast_data["filmography"][x]["job"], actor.filmography[x].job
#        assert_equal @cast_data["filmography"][x]["department"], actor.filmography[x].department
#        assert_equal @cast_data["filmography"][x]["character"], actor.filmography[x].character
#        assert_equal @cast_data["filmography"][x]["url"], actor.filmography[x].url
#      end
#      @cast_data["filmography"].each_index do |x|
#        assert_equal TmdbMovie.find(:id => @cast_data["filmography"][x]["id"]), actor.movies[x]
#      end
#      @cast_data["profile"].each_index do |x|
#        assert_equal @cast_data["profile"][x]["image"]["type"], actor.profiles[x].type
#        assert_equal @cast_data["profile"][x]["image"]["size"], actor.profiles[x].size
#        assert_equal @cast_data["profile"][x]["image"]["height"], actor.profiles[x].height
#        assert_equal @cast_data["profile"][x]["image"]["width"], actor.profiles[x].width
#        assert_equal @cast_data["profile"][x]["image"]["url"], actor.profiles[x].url
#        assert_equal @cast_data["profile"][x]["image"]["id"], actor.profiles[x].id
#        assert_equal Tmdb.get_url(@cast_data["profile"][x]["image"]["url"]), actor.profiles[x].data
#      end
#    end
#  end
#  
#  test "should raise exception if no arguments supplied to find" do
#    assert_raise ArgumentError do
#      TmdbCast.find()
#    end
#  end
#
#  test "find by id should return a single cast member" do
#    assert_kind_of TmdbCast.find(:id => 287), "TmdbCast"
#  end
#  
#  test "find by name should return an array of cast members" do
#    cast_members = TmdbCast.find(:name => "vince")
#    assert_kind_of cast_members, "Array"
#    cast_members.each do |actor|
#      assert_kind_of actor, "TmdbCast"
#    end
#  end

end