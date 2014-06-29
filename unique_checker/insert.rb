require 'dbi'
require 'digest/md5'
require 'mini_exiftool'

if ARGV[0] == nil
  puts "input TARGET_DIR by params."
  puts "usage: ruby " + $0 + " TARGET_DIR"
  exit
end

def directorize(path)
  if path.end_with?('/') then
    return path
  else
    return path + "/"
  end
end

# change if conditions for your target
def get_model(photo)
  if photo["Model"] != nil
    return photo.Model.to_s
  elsif photo["Model-jpn"] != nil
    return photo.Model_jpn.to_s
  elsif photo.filename.include?("MAH0")
    return "DSC-HX5V"
  elsif photo.filename.include?("video-")
    return "GT-S5660"
  elsif photo.filename.include?("VID_") || photo.filename.include?("PANO_")
    return "Nexus 5"
  else
    return "????"
  end
end

def get_date(photo)
  if photo.MediaModifyDate != nil
    return DateTime.strptime(photo.MediaModifyDate.to_s, "%Y-%m-%d %H:%M:%S").to_s
  elsif photo.DateTimeOriginal != nil
    return DateTime.strptime(photo.DateTimeOriginal.to_s, "%Y-%m-%d %H:%M:%S").to_s
  else
    return DateTime.strptime(photo.FileModifyDate.to_s, "%Y-%m-%d %H:%M:%S").to_s
  end
end

def is_image(file_path)
  extension = File.extname(file_path).downcase
  targets = [".jpg", ".avi", ".mp4", ".mov", ".nef", ".cr2"]
  targets.include?(extension)
end

dbh = DBI.connect('DBI:SQLite3:photo.db')
Dir.glob([directorize(ARGV[0]) + '**/*']) do |f|
  begin
    if !is_image(f.to_s) then
      next
    end

    photo = MiniExiftool.new(f)
    digest = Digest::MD5.file(f).to_s
    date = get_date(photo)
    model = get_model(photo)

    puts f.to_s + ", " + digest + ", " + date + ", " + model
    
    sql = "insert into photo(path, md5, date_time_original, model) values (? ,?, ?, ?)"
    dbh.do(sql, f.to_s, digest, date, model)
  rescue => e
    puts e.message + ", " + f.to_s
    dbh.do("insert into failure(path) values (?)", f.to_s)
  end
end
dbh.disconnect
