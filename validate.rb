require "sequel"
require "digest/md5"

# TODO final goal is to send email if some file is broken.

DB = Sequel.sqlite('photo/photo.db')
photo = DB[:photo].all
broken_files = []

# use "order by" if you resume
DB.fetch("select path, md5 from photo"){|item|
	current_md5 = Digest::MD5.file("photo/" + item[:path])
	past_md5 = item[:md5]
	if (current_md5 != past_md5)
		broken_files.push(item[:path])
	end
}

if not broken_files.empty?
	puts "broken files are ..."
	puts broken_files.sort!
else
	puts "ALL REGISTERED FILES ARE NOT BROKEN."
end

