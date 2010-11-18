require_files = []
require_files << File.join(File.dirname(__FILE__), '..', '..', 'lib', 'ruby-tmdb.rb')
#require_files.concat Dir[File.join(File.dirname(__FILE__), 'setup', '*.rb')]

require_files.each do |file|
  require File.expand_path(file)
end

puts "Hello"

Tmdb.api_key = "869bc2f39a7ab330a7215387d4510dbb"
movies = TmdbMovie.browse(:params => {:order_by => "rating", :order => "desc", :genres => 18, :min_votes => 5, :page => 1, :per_page => 10})
balh = 12