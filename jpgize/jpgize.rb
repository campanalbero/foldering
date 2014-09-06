# usage: ruby jpgize.rb FROM_DIR TO_DIR

require 'rubygems'
require 'RMagick'
require 'mini_exiftool'
require 'logger'

FROM = ARGV[0]
TO = ARGV[1]

log = Logger.new('failure.log')
log.level = Logger::WARN

Dir.glob(FROM + '**/*').sort{|a, b| a <=> b}.each do |f|

	# .NEF は Nikon, .CR2 は Canon の raw ファイル
	ext = File.extname(f).downcase
	if (ext != '.jpg' && ext != '.nef' && ext != '.cr2')
		next
	end

	# 拡張子を置き換えせずに、 .jpg を追加しているのは、置き換えだと名前が被りうるから。
	# e.g. DSC_0001.JPG, DSC_0001.NEF
	dst = TO + f.to_s.slice(FROM.length..f.to_s.length) + ".jpg"
	dir = File.dirname(dst)
	FileUtils::mkdir_p(dir) unless FileTest.exist?(dir)

	begin
		input = Magick::Image.read(f).first
		if (input.columns > 2048 || input.rows > 2048)
			# 長辺が 2048px になるように縮小。
			# iPad 3 のディスプレイと Picasa のアップロードサイズの都合。
			resized = input.resize_to_fit(2048, 2048)
			resized.write(dst)

			# exif データは元画像からコピペ
			exif = MiniExiftool.new(dst)
			exif.copy_tags_from(f, 'all')
			exif.save
		else
			# 拡大されても嬉しくないので、ただのコピー
			input.write(dst)
		end

		puts f
	rescue
		# 失敗したファイル名はタブ文字で字下げして表示
		puts '	' + f
		log.error(f)
	end
end
