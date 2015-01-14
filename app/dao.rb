require "digest/md5"
require "logger"
require "mini_exiftool"
require "pathname"
require "sequel"
require "date"

batch_log = "log/batch.log"
File.rename(batch_log, "log/" + DateTime.now.to_s + ".log") if FileTest.exist?(batch_log)
$log = Logger.new(batch_log)

module Db
	def insert(entity)
		begin
			db = Sequel.sqlite('photo/photo.db')
			db[:photo].insert(:path => entity.future_path, :md5 => entity.md5, :date_time => entity.date, :model => entity.model)
		rescue => e
	 		$log.error(__method__.to_s + ", " + File.expand_path(entity.future_path) + ", " + e.message)
		end
	end

	def exist?(md5)
		begin
			not DB[:photo].where(":md5 => md5").select(:path).all.empty?
		rescue => e
	 		$log.error(__method__.to_s + ", " + md5 + ", " + e.message)
		end
	end

	module_function :insert
	module_function :exist?
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
		exif = MiniExiftool.new(current_path)
		@md5 = Digest::MD5.file(current_path).to_s
		@date = get_date(exif)
		@model = get_model(exif)
		@future_path = yyyymmdd(@date) + "/" + File.basename(current_path)
		@current_path = current_path
	end

	attr_reader :future_path
	attr_reader :current_path
	attr_reader :md5
	attr_reader :date
	attr_reader :model
end

class Media
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
end
