require 'mini_exiftool'

# TODO test
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
