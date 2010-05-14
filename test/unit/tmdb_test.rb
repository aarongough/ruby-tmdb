require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class TmdbTest < Test::Unit::TestCase

  test "allows setting of api_key" do
    api_key = "test1234567890"
    Tmdb.api_key = api_key
    assert_equal Tmdb.api_key, api_key
  end

  test "get url returns a response object" do
    test_response = Tmdb.get_url("http://example.com/")
    assert_equal 200, test_response.code.to_i
  end
  
  test "getting nonexistent URL returns response object" do
    test_response = Tmdb.get_url('http://thisisaurlthatdoesntexist.co.nz')
    assert_equal 404, test_response.code.to_i
  end

end