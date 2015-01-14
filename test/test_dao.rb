require 'minitest/unit'
require './app/sort.rb'

MiniTest::Unit.autorun

class TestDao < MiniTest::Unit::TestCase
	def setup
		# do something
		# flush dir
		# prepare image files
	end

	def teardown
		# do something
	end

#	def test_move
#		day = Time.now
#		File.rename('tmp', 'tmp' + day.year.to_s + day.month.to_s + day.day.to_s + day.hour.to_s + day.min.to_s + day.sec.to_s)
		#FileUtils.rm_rf('tmp')
#		File.rename('photo', 'tmp')
#		assert_equal false, File.exist?('photo')
#		system('ruby sort.rb')
#		assert_equal true, File.exist?('photo')
#	end

	def test_jpg_image?
		assert_equal true, Media.image?("IMG_20150101_000000.jpg")
	end

	def test_JPG_image?
		assert_equal true, Media.image?("IMAGE.JPG")
	end

	def test_CR2_image?
		assert_equal true, Media.image?("IMG_9999.CR2")
	end

	def test_NEF_image?
		assert_equal true, Media.image?("DSC_0000.NEF")
	end

	def test_txt_image?
		assert_equal false, Media.image?("document.txt")
	end

	# because of ruby 1.9.x, no multi-byte charactors are allowed
	#def test_jp_image?
	#	assert_equal true, Media.image?("イメージ.jpg")
	#end
end

