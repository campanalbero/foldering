require "digest/md5"
require "logger"
require "mini_exiftool"
require "sequel"
require "date"

batch_log = "log/batch.log"
File.rename(batch_log, "log/" + DateTime.now.to_s + ".log") if FileTest.exist?(batch_log)
$log = Logger.new(batch_log)

module Dao
	def insert(entity)
		begin
			db = Sequel.sqlite('photo/photo.db')
			db[:photo].insert(:path => entity.future_path, :md5 => entity.md5, :date_time => entity.date, :model => entity.model)
		rescue => e
	 		$log.error(__method__.to_s + ", " + File.expand_path(entity.future_path) + ", " + e.message)
		end
	end

	def exist?(md5)
		begin
			not DB[:photo].where(":md5 => md5").select(:path).all.empty?
		rescue => e
	 		$log.error(__method__.to_s + ", " + md5 + ", " + e.message)
		end
	end

	module_function :insert
	module_function :exist?
end

