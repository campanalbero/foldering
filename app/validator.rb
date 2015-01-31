require "sequel"
require "digest/md5"

# TODO final goal is to send email if some file is broken.

module Validator

	def validate_all
		db = Sequel.sqlite('photo/photo.db')
		broken_files = []
		lost_files = []
		# use "order by" if you resume
		db.fetch("select path, md5 from photo"){|item|
			path = "photo/" + item[:path]
		
			if (not File::exist?(path))
				lost_files.push(path)
				next
			end
		
			current_md5 = Digest::MD5.file(path)
			past_md5 = item[:md5]
			if (current_md5 != past_md5)
				broken_files.push(path)
			end
		}
		
		if broken_files.empty? and lost_files.empty?
			puts "All registered files are OK."
		else
			puts "broken files are..."
			puts broken_files
			puts "----"
			puts "lost_files are ..."
			puts lost_files
		end
	end

	module_function :validate_all

end

