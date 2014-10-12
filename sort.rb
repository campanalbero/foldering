require "digest/md5"
require "logger"
require "mini_exiftool"
require "pathname"
require "sequel"

$log = Logger.new("batch.log")

module Db
	def insert_into_db(relative_path)
		begin
			exif = Exif.new(relative_path)
			digest = Digest::MD5.file(relative_path).to_s
			date = exif.get_date.to_s
			model = exif.get_model

			dir = "photo/"
			db = Sequel.sqlite(dir + "photo.db")
			relative_path_from_dir = Pathname.new(relative_path).relative_path_from(Pathname.new(dir))
			db[:photo].insert(:path => relative_path_from_dir.to_s, :md5 => digest, :date_time_original => date, :model => model)
		rescue => e
	 		$log.error(__method__.to_s + ", " + File.expand_path(relative_path) + ", " + e.message)
		end
	end

	# 異動したファイルをキューに積んで、別プログラムで何かしら処理をする
	def insert_into_queue(relative_path)
		begin
			dir = "resized/"
			queue = Sequel.sqlite(dir + "queue.db")
			relative_path_from_dir = Pathname.new(relative_path).relative_path_from(Pathname.new(dir))
			queue[:queue].insert(:path => relative_path_from_dir.to_s)
		rescue => e
	 		$log.error(__method__.to_s + ", " + File.expand_path(relative_path) + ", " + e.message)
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
	if path.end_with?("/") then
		path
	else
		path + "/"
	end
end

# 引数のタイムスタンプから yyyy/mm/dd という文字列を返す
def yyyymmdd(timestump)	
	yyyy = timestump.strftime("%Y")
	mm = timestump.strftime("%m")
	dd = timestump.strftime("%d")
	yyyy + "/" + mm + "/" + dd
end

puts("from, to")
# photo/ フォルダ以下に決め打ち
# tmp/ フォルダ以下に決め打ち
Dir.glob(["tmp/**/*"]) do |f|
	if not Exif.target?(f) then
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
		$log.error(f + " already exist")
	end
end
