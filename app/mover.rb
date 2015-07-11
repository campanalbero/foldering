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
			if (FileTest.exist?(dst))
				if (Dao.exist?(entity.md5))
					$logger.error(f + " is duplicated.")
					#File.delete(src)
				else
					$log.info(src + " already exist, but they are different.")
				end
			else
				puts(src + ", " + dst)
				begin
					Dao.insert(entity)
					FileUtils::mkdir_p(File::dirname(dst))
					File.rename(src, dst)
					# TODO 移動先にファイルがあるけど DB に保存されていない場合
				rescue
					dup = File.expand_path("duplicated/" + entity.current_path)
					FileUtils::mkdir_p(File::dirname(dup))
					File.rename(src, dup)
				end
			end
		end

		Deleter::remove_ini()
		Deleter::remove_ds_store()
		Deleter::remove_empty_dir()
	end

	module_function :move_all
end
