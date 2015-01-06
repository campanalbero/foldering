require "digest/md5"
require "logger"
require "mini_exiftool"
require "pathname"
require "sequel"

$log = Logger.new("batch.log")

# ROOT/tmp/FOLDER/IMAGE_FILE
# ROOT/photo/photo.db
# ROOT/photo/yyyy-mm-dd/FILE_NAME.EXT
# ROOT/resized/queue.db
# ROOT/resized/yyyy-mm-dd/FILE_NAME.EXT.jpg

module Db
	@@queue_dir = "resized/"
	def insert_into_db(entity)
		begin
			db = Sequel.sqlite("photo/photo.db")
			db[:photo].insert(:path => entity.path, :md5 => entity.md5, :date_time_original => entity.date, :model => entity.model)
		rescue => e
	 		$log.error(__method__.to_s + ", " + File.expand_path(entity.path) + ", " + e.message)
		end
	end

	# split this
	# 移動したファイルをキューに積んで、別プログラムで何かしら処理をする
	def insert_into_queue(relative_path)
		begin
			queue = Sequel.sqlite(@@queue_dir + "queue.db")
			relative_path_from_dir = Pathname.new(relative_path).relative_path_from(Pathname.new(@@queue_dir))
			queue[:queue].insert(:path => relative_path_from_dir.to_s)
		rescue => e
	 		$log.error(__method__.to_s + ", " + File.expand_path(relative_path) + ", " + e.message)
		end
	end

	module_function :insert_into_db
	module_function :insert_into_queue
end

class Entity
	# 引数のタイムスタンプから yyyy-mm-dd という文字列を返す
	def yyyymmdd(timestump)	
		yyyy = timestump.strftime("%Y")
		mm = timestump.strftime("%m")
		dd = timestump.strftime("%d")
		yyyy + "-" + mm + "-" + dd
	end

	# 作成日を得る
	def get_date(exif)
		if exif.MediaModifyDate != nil
			exif.MediaModifyDate
		elsif exif.DateTimeOriginal != nil
			exif.DateTimeOriginal
		else
			exif.FileModifyDate
		end
	end

	# 撮影したカメラモデルを得る（あくまで俺の持ってたカメラ）
	def get_model(exif)
		if exif["Model"] != nil
			exif["Model"]
		elsif exif["Model-jpn"] != nil
			exif["Model-jpn"]
		elsif exif.filename.include?("MAH0")
			"DSC-HX5V"
		elsif exif.filename.include?("video-")
			"GT-S5660"
		elsif exif.filename.include?("VID_") || exif.filename.include?("PANO_")
			"Nexus 5"
		else
			"????"
		end
	end

	def initialize(current_path)
		exif = MiniMediatool.new(current_path)
		@md5 = Digest::MD5.file(current_path).to_s
		@date = get_date(exif)
		@model = get_model(exif)
		@path = yyyymmdd(@date) + "/" + File.basename(current_path)
	end

	attr_reader :path #change it, is this current path or future one?
	attr_reader :md5
	attr_reader :date
	attr_reader :model
end

class Media
	private def self.image?(path)
		extension = File.extname(path).downcase
		targets = [".jpg", ".nef", ".cr2"]
		targets.include?(extension)
	end

	private def self.movie?(path)
		extension = File.extname(path).downcase
		targets = [".avi", ".mp4", ".mov"]
		targets.include?(extension)
	end

	def self.target?(path)
		image?(path) or movie?(path)
	end
end

puts("from, to")
# photo/ フォルダ以下に決め打ち
# tmp/ フォルダ以下に決め打ち
Dir.glob(["tmp/**/*"]) do |f|
	if not Media.target?(f) then
		next
	end
	entity = Entity.new(f)
	dst = "photo/" + entity.path
	new_dir = File::dirname(dst)
	FileUtils::mkdir_p(new_dir) unless FileTest.exist?(new_dir)
	if (not FileTest.exist?(dst))
		puts(File.expand_path(f) + ", " + File.expand_path(dst))
		File.rename(f, dst)
		Db.insert_into_db(entity)
		Db.insert_into_queue(dst)
	else
		$log.error(f + " already exist")
	end
end

