require 'logger'

require './exif.rb'
require './db.rb'

# 引数1, 2 が入力されているかどうかをチェックする
if ARGV[0] == nil || ARGV[1] == nil
	puts "input FROM_DIR and TO_DIR by params."
	puts "usage: ruby " + $0 + " FROM_DIR TO_DIR"
	exit
end

# 引数(path)の末尾が / になったものを返す
def directorize(path)
	if path.end_with?('/') then
		path
	else
		path + "/"
	end
end

# 引数のタイムスタンプから yyyy/mm/dd という文字列を返す
def yyyymmdd(timestump)	
	yyyy = timestump.strftime('%Y')
	mm = timestump.strftime('%m')
	dd = timestump.strftime('%d')
	yyyy + "/" + mm + "/" + dd
end

log = Logger.new(STDOUT)
log.level = Logger::INFO
log.info("from, to")
Dir.glob([directorize(ARGV[0]) + '**/*']) do |f|
	if not Exif.target?(f) then
		log.debug(f + " is not image nor movie")
		next
	end
	timestump = Exif.get_date(f)
	new_dir = directorize(ARGV[1]) + yyyymmdd(timestump)
	dst = new_dir + "/" + File.basename(f)
	FileUtils::mkdir_p(new_dir) unless FileTest.exist?(new_dir)
	if (not FileTest.exist?(dst))
		log.info(f + ", " + dst)
		Db.insert_into_db(f)
		File.rename(f, dst)
	else
		log.error(f + " already exist")
	end
end

