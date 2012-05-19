begin
  file_path = File.absolute_path('tmdb_api_key.txt', File.dirname(__FILE__))

  File.open(file_path) do |file|
    Tmdb.api_key = file.read
  end
rescue Errno::ENOENT => e
  $stderr.puts "You need place your api key in #{file_path}"
  exit
end