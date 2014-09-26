require 'rubygems'
require 'sqlite3'
require 'dbi'

begin
	db = SQLite3::Database.new("photo.db")
	dbh = DBI.connect('DBI:SQLite3:photo.db')
	dbh.do("create table photo(path UNIQUE, md5 UNIQUE, date_time_original, model)")
rescue => e
	puts e.message
ensure
	dbh.disconnect
end
