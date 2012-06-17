begin
  File.open(File.join(File.dirname(__FILE__), 'tmdb_api_key.txt')) do |file|
    Tmdb.api_key = file.read
  end
rescue Errno::ENOENT => e
  puts "\n\nERROR: The TMDB API key could not be found, please add an API key to 'setup/tmdb_api_key.txt'\n\n"
  exit
end