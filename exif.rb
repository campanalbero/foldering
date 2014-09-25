require 'mini_exiftool'

# TODO test
module Exif

	def image?(path)
		extension = File.extname(path).downcase
		targets = [".jpg", ".nef", ".cr2"]
		targets.include?(extension)
	end

	def movie?(path)
		extension = File.extname(path).downcase
		targets = [".avi", ".mp4", ".mov"]
		targets.include?(extension)
	end

	def target?(path)
		image?(path) or movie?(path)
	end

	# 作成日を得る
	def get_date(path)
		exif = MiniExiftool::new(path)

		if exif.MediaModifyDate != nil
			exif.MediaModifyDate
		elsif exif.DateTimeOriginal != nil
			exif.DateTimeOriginal
		else
			exif.FileModifyDate
		end
	end

	# 撮影したカメラモデルを得る（あくまで俺の持ってたカメラ）
	def get_model(path)
		exif = MiniExiftool::new(path)

		if exif["Model"] != nil
			exif.Model.to_s
		elsif exif["Model-jpn"] != nil
			exif.Model_jpn.to_s
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

	module_function :image?
	module_function :movie?
	module_function :target?
	
	module_function :get_date
	module_function :get_model
end
