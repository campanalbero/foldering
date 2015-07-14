require "digest/md5"
require "mini_exiftool"
require "sequel"
require "date"
require "yaml"

module Dao

	config = YAML.load_file("config.yml")
	DB = Sequel.mysql(config["db_schema"], :host=>config["db_url"], :user=>config["db_user"], :password=>config["db_password"], :port=>config["db_port"])
	def insert(entity)
		DB[:photo].insert(:path => entity.future_path, :md5 => entity.md5, :date_time => entity.date, :model => entity.model)
	end

	def exist?(md5)
		begin
			not DB[:photo].where(":md5 => md5").select(:path).all.empty?
		rescue => e
	 		$logger.error(__method__.to_s + ", " + md5 + ", " + e.message)
		end
	end

	module_function :insert
	module_function :exist?
end
