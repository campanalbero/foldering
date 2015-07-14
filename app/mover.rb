require "logger"
require 'date'
require "sequel"
require './app/deleter.rb'
require './app/media_dao.rb'

module Mover
	def self.move(prefix, src)
		dst = File.expand_path(prefix + File.basename(src))
		FileUtils::mkdir_p(File::dirname(dst))
		File.rename(src, dst)
	end

	def move_all
		puts("from, to")
		# photo/ フォルダ以下に決め打ち
		# tmp/ フォルダ以下に決め打ち
		Dir.glob(["tmp/**/*"]) do |f|
			if not MediaEntity.target?(f) then
				next
			end
			entity = MediaEntity.new(f)
			src = File.expand_path(f)
			dst = File.expand_path("photo/" + entity.future_path)
  		begin
				Dao.insert(entity)
				FileUtils::mkdir_p(File::dirname(dst))
				File.rename(src, dst)
				puts(src + ", " + dst)
				$logger.info(src + ", " + dst)
      rescue Sequel::UniqueConstraintViolation => e
				move("duplicated/", src)
				p e
				$logger.error e
			rescue => e
				move("something_wrong/", src)
				p e
				$logger.error e
			end
		end

		Deleter::remove_ini()
		Deleter::remove_ds_store()
		Deleter::remove_empty_dir()
	end

	module_function :move_all
end
