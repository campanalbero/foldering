require 'rmagick'
require './app/media_entity.rb'

module Resizer
	def resize(from, to)
		puts from + ", " + to 
		image = Magick::Image.read(from).first
		image.resize(2048, 2048)
		image.write(to)
	end

	def resize_all
		puts("from, to")
		# photo/ フォルダ以下に決め打ち
		# thumb/ フォルダ以下に決め打ち
		Dir.glob(["photo/**/*"]) do |f|
		
			if not MediaEntity.image?(f) then
				next
			end
			dst = f.to_s.sub("photo/", "thumb/") + ".jpg"
			if (not FileTest.exist?(dst))
				FileUtils::mkdir_p(File::dirname(dst))
				resize(f, dst)
			else
				$logger.info(f + " already exist")
			end
		end
	end

	module_function :resize
	module_function :resize_all
end
	
