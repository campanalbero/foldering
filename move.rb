require "logger"
require "./app/dao.rb"
require "./app/MediaEntity.rb"
require "./app/RemoveDust.rb"

batch_log = "log/move.log"
File.rename(batch_log, "log/" + DateTime.now.to_s + ".log") if FileTest.exist?(batch_log)
$log = Logger.new(batch_log)

puts("from, to")
# photo/ フォルダ以下に決め打ち
# tmp/ フォルダ以下に決め打ち
Dir.glob(["tmp/**/*"]) do |f|
	if not MediaEntity.target?(f) then
		next
	end
	entity = MediaEntity.new(f)
	FileUtils::mkdir_p(File::dirname(entity.future_path))
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

RemoveDust::remove_ds_store()
RemoveDust::remove_empty_dir()
## Only for *nix
#system('find tmp -name .DS_Store | xargs rm')
#
#sorted = Dir.glob(["tmp/**/*"]).sort{|a,b| b.split('/').length <=> a.split('/').length
#}
#sorted.each{|f|
#	puts f
#	Dir.rmdir(f) if File::ftype(f) == "directory" and Dir.entries(f).size == 2
#}
#
