require 'minitest/unit'
require './sort'

MiniTest::Unit.autorun

class TestSort < MiniTest::Unit::TestCase
	def setup
		# do something
	end

	def teardown
		# do something
	end

	def test_jpg_image?
		assert_equal true, Media.image?("image.jpg")
	end

	def test_JPG_image?
		assert_equal true, Media.image?("IMAGE.JPG")
	end

	def test_txt_image?
		assert_equal false, Media.image?("document.txt")
	end

	# because of ruby 1.9.x, no multi-byte charactors are allowed
	#def test_jp_image?
	#	assert_equal true, Media.image?("イメージ.jpg")
	#end
end

