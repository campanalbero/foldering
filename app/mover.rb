require "logger"
require 'date'
require './app/deleter.rb'

batch_log = "log/move.log"
File.rename(batch_log, "log/" + DateTime.now.to_s + ".log") if FileTest.exist?(batch_log)
$log = Logger.new(batch_log)

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
				if (DbDao.exist?(entity.md5))
					$log.error(f + " is duplicated.")
					File.delete(src)
				else
					$log.info(src + " already exist, but they are different.")
				end
			else
				puts(src + ", " + dst)
				FileUtils::mkdir_p(File::dirname(dst))
				File.rename(src, dst)
				Db.insert(entity)
				# TODO 移動先にファイルがあるけど DB に保存されていない場合
			end
		end
		
		Deleter::remove_ds_store()
		Deleter::remove_empty_dir()
	end

	module_function :move_all
end
	
