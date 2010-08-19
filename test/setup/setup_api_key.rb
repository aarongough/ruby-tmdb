File.open(File.join(File.dirname(__FILE__), 'tmdb_api_key.txt')) do |file|
  Tmdb.api_key = file.read
end