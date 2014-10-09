require 'logger'
require 'dbi'
require 'digest/md5'
require 'mini_exiftool'

module Db
	Log = Logger.new("err.log")
	Photo_db = DBI.connect('DBI:SQLite3:photo/photo.db')
	def insert_into_db(path)
		begin
			photo_sql = "insert into photo(path, md5, date_time_original, model) values (? ,?, ?, ?)"
			exif = Exif.new(path)
			digest = Digest::MD5.file(path).to_s
			date = exif.get_date.to_s
			model = exif.get_model

			Photo_db.do(photo_sql, path, digest, date, model)
		rescue => e
	 		Log.error(__method__.to_s + ", " + path + ", " + e.message)
	 	ensure
		#	Photo_db.disconnect
		end
	end

	Queue_db = DBI.connect('DBI:SQLite3:resized/queue.db')
	def insert_into_queue(path)
		begin
			queue_sql = "insert into queue(path) values (?)"
			Queue_db.do(queue_sql, path)
		rescue => e
	 		Log.error(__method__.to_s + ", " + path + ", " + e.message)
	 	ensure
		#	Queue_db.disconnect
		end
	end

	module_function :insert_into_db
	module_function :insert_into_queue
end

class Exif

	def initialize(path)
		@exif = MiniExiftool::new(path)
	end

	def self.image?(path)
		extension = File.extname(path).downcase
		targets = [".jpg", ".nef", ".cr2"]
		targets.include?(extension)
	end

	def self.movie?(path)
		extension = File.extname(path).downcase
		targets = [".avi", ".mp4", ".mov"]
		targets.include?(extension)
	end

	def self.target?(path)
		image?(path) or movie?(path)
	end

	# 作成日を得る
	def get_date
		if @exif.MediaModifyDate != nil
			@exif.MediaModifyDate
		elsif @exif.DateTimeOriginal != nil
			@exif.DateTimeOriginal
		else
			@exif.FileModifyDate
		end
	end

	# 撮影したカメラモデルを得る（あくまで俺の持ってたカメラ）
	def get_model
		if @exif["Model"] != nil
			@exif["Model"]
		elsif @exif["Model-jpn"] != nil
			@exif["Model-jpn"]
		elsif @exif.filename.include?("MAH0")
			"DSC-HX5V"
		elsif @exif.filename.include?("video-")
			"GT-S5660"
		elsif @exif.filename.include?("VID_") || @exif.filename.include?("PANO_")
			"Nexus 5"
		else
			"????"
		end
	end
end

# 引数(path)の末尾が / になったものを返す
def directorize(path)
	if path.end_with?('/') then
		path
	else
		path + "/"
	end
end

# 引数のタイムスタンプから yyyy/mm/dd という文字列を返す
def yyyymmdd(timestump)	
	yyyy = timestump.strftime('%Y')
	mm = timestump.strftime('%m')
	dd = timestump.strftime('%d')
	yyyy + "/" + mm + "/" + dd
end

log = Logger.new("err.log")
log.level = Logger::INFO
puts("from, to")
Dir.glob(['tmp/**/*']) do |f|
	if not Exif.target?(f) then
		#log.error(f + " is not image nor movie")
		next
	end
	exif = Exif.new(f)
	timestump = exif.get_date
	new_dir = "photo/" + yyyymmdd(timestump)
	dst = new_dir + "/" + File.basename(f)
	FileUtils::mkdir_p(new_dir) unless FileTest.exist?(new_dir)
	if (not FileTest.exist?(dst))
		puts(File.expand_path(f) + ", " + File.expand_path(dst))
		File.rename(f, dst)
		Db.insert_into_db(dst)
		Db.insert_into_queue(dst)
	else
		log.error(f + " already exist")
	end
end
