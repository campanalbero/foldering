require 'rubygems'
require 'sqlite3'
require 'dbi'

begin
	db = SQLite3::Database.new("photo.db")
	dbh = DBI.connect('DBI:SQLite3:photo.db')

	create_photo_table = "create table photo(path, md5, date_time_original, model)"
	dbh.do(create_photo_table)

	create_failure_table = "create table failure(path)"
	dbh.do(create_failure_table)
rescue => e
	puts e.message
end
dbh.disconnect
