require 'mini_exiftool'

if ARGV[0] == nil || ARGV[1] == nil
	puts "input FROM and TO directories by params."
	puts "usage: ruby " + $0 + " FROM_DIR TO_DIR"
	exit
end

def directorize(path)
	if path.end_with?('/') then
		return path
	else
		return path + "/"
	end
end

def get_date(photo)
	if photo.MediaModifyDate != nil
		return DateTime.strptime(photo.MediaModifyDate.to_s, "%Y-%m-%d %H:%M:%S")
	elsif photo.DateTimeOriginal != nil
		return DateTime.strptime(photo.DateTimeOriginal.to_s, "%Y-%m-%d %H:%M:%S")
	else
		return DateTime.strptime(photo.FileModifyDate.to_s, "%Y-%m-%d %H:%M:%S")
	end
end

def get_dir(timestump)
	yyyy = timestump.strftime('%Y')
	mm = timestump.strftime('%m')
	dd = timestump.strftime('%d')
	dir = directorize(ARGV[1]).to_s + yyyy + '/' + mm + '/' + dd
end

def is_image(file_path)
	extension = File.extname(file_path).downcase
	targets = [".jpg", ".avi", ".mp4", ".mov", ".nef", ".cr2"]
	targets.include?(extension)
end

puts "from, to"
Dir.glob([directorize(ARGV[0]) + '**/*']) do |f|
	print f.to_s + ", "
	if !is_image(f.to_s) then
		puts "not image"
		next
	end
	timestump = get_date(MiniExiftool::new(f))
	dir = get_dir(timestump)
	dist = dir + "/" + File.basename(f.to_s)
	puts dist
	FileUtils::mkdir_p(dir) unless FileTest.exist?(dir)
	File.rename(f, dist) unless FileTest.exist?(dist)
end
