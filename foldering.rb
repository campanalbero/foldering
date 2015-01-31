require './app/mover.rb'
require './app/resizer.rb'
require './app/validator.rb'

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

