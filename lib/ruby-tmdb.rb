require "rubygems"

require_files = []
require_files.concat Dir[File.join(File.dirname(__FILE__), 'ruby-tmdb', '*.rb')]

require_files.each do |file|
  require File.expand_path(file)
end