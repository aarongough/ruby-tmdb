require_files = []
require_files.concat Dir[File.join(File.dirname(__FILE__), 'ruby_tmdb', '*.rb')]

require_files.each do |file|
  require File.expand_path(file)
end