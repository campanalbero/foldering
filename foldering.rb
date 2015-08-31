require 'logger'
require 'yaml'
require './app/foldering_config.rb'
require './app/mover.rb'
require './app/resizer.rb'
require './app/validator.rb'

conf = FolderingConfig.new('development')
log_path = conf.log_dir.to_s + "app.log"
if File::exist?(log_path)
  timestump = File::stat(log_path).mtime.strftime("%Y%m%d-%H%M%S")
  File.rename(log_path, conf.log_dir.to_s + timestump.to_s + ".log")
end
$logger = Logger.new(log_path)
$logger.level = Logger::DEBUG

case ARGV[0]
when "move" then
	Mover.move_all
when "resize" then
	Resizer.resize_all
when "validate" then
	Validator.validate_all
else
	puts "usage..."
	puts "  move"
	puts "  resize"
	puts "  validate"
end

