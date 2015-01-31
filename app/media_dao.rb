require "digest/md5"
require "mini_exiftool"
require "sequel"
require "date"

module Dao
	def insert(entity)
		begin
			db = Sequel.sqlite('photo/photo.db')
			db[:photo].insert(:path => entity.future_path, :md5 => entity.md5, :date_time => entity.date, :model => entity.model)
		rescue => e
	 		$logger.error(__method__.to_s + ", " + File.expand_path(entity.future_path) + ", " + e.message)
		end
	end

	def exist?(md5)
		begin
			not DB[:photo].where(":md5 => md5").select(:path).all.empty?
		rescue => e
	 		$loggr.error(__method__.to_s + ", " + md5 + ", " + e.message)
		end
	end

	module_function :insert
	module_function :exist?
end

