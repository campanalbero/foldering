require 'dbi'
require 'digest/md5'
require './exif.rb'

# TODO test
module Db
	log = Logger.new("db.log")
	log.level = Logger::INFO
	Photo_sql = "insert into photo(path, md5, date_time_original, model) values (? ,?, ?, ?)"
	def insert_into_db(path)
		photo_db = DBI.connect('DBI:SQLite3:photo.db')
		begin
			exif = Exif.new(path)

			digest = Digest::MD5.file(path).to_s
			date = exif.get_date.to_s
			model = exif.get_model
			photo_db.do(Photo_sql, path, digest, date, model)

			#if exif.image? then
		 	#	# TODO insert queue
			#end
		rescue => e
	 		log.error(path + ", " + e.message)
	 	ensure
			photo_db.disconnect
		end
	end

	module_function :insert_into_db
end
