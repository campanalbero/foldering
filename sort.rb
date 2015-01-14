require "logger"
require "./app/dao.rb"

batch_log = "log/batch.log"
File.rename(batch_log, "log/" + DateTime.now.to_s + ".log") if FileTest.exist?(batch_log)
$log = Logger.new(batch_log)

def mkdir_f(path)
	dst = "photo/" + path
	new_dir = File::dirname(dst)
	FileUtils::mkdir_p(new_dir) unless FileTest.exist?(new_dir)
end

puts("from, to")
# photo/ フォルダ以下に決め打ち
# tmp/ フォルダ以下に決め打ち
Dir.glob(["tmp/**/*"]) do |f|
	if not Media.target?(f) then
		next
	end
	entity = Entity.new(f)
	mkdir_f(entity.future_path)
	dst = "photo/" + entity.future_path
	if (FileTest.exist?(entity.future_path))
		if (Db.exist?(entity.md5))
			$log.error(f + " is duplicated.")
			File.delete(f)
		else
			$log.info(f + " already exist, but they are different.")
		end
	else
		puts(File.expand_path(f) + ", " + File.expand_path(dst))
		File.rename(f, dst)
		Db.insert(entity)
		# TODO 移動先にファイルがあるけど DB に保存されていない場合
	end
end

