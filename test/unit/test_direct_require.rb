require "test/unit"

require_files = []
require_files << File.join(File.dirname(__FILE__), "..", "..", "lib", "ruby-tmdb.rb")
require_files.concat Dir[File.join(File.dirname(__FILE__), '..', 'setup', '*.rb')]

require_files.each do |file|
  require File.expand_path(file)
end

class DirectRequireTest < Test::Unit::TestCase
  
  test "TmdbMovie should not raise exception when directly required without using rubygems" do
    assert_nothing_raised do
      TmdbMovie.find(:id => 187)
    end
  end
  
  test "TmdbCast should not raise exception when directly required without using rubygems" do
    assert_nothing_raised do
      TmdbCast.find(:id => 287)
    end
  end
  
end