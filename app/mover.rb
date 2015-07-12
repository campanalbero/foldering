require "logger"
require 'date'
require './app/deleter.rb'
require './app/media_dao.rb'

module Mover
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
			if not FileTest.exist?(dst) then
				begin
					Dao.insert(entity)
					FileUtils::mkdir_p(File::dirname(dst))
					File.rename(src, dst)
					puts(src + ", " + dst)
					$logger.info(src + ", " + dst)
				rescue
					dup = File.expand_path("duplicated/" + entity.current_path)
					FileUtils::mkdir_p(File::dirname(dup))
					File.rename(src, dup)
					puts(entity.current_path + " is duplicated.")
					$logger.error(entity.current_path + " is duplicated.")
				end
			else
				dup = File.expand_path("same_name/" + entity.current_path)
				FileUtils::mkdir_p(File::dirname(dup))
				File.rename(src, dup)
				puts(src + " already exist.")
				$log.error(src + " already exist.")
			end
		end

		Deleter::remove_ini()
		Deleter::remove_ds_store()
		Deleter::remove_empty_dir()
	end

	module_function :move_all
end
