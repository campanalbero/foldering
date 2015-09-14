require 'find'

class Deleter
	def self.remove(file_name)
		Find.find('tmp'){|f|
			if f.include?(file_name)
				File.delete(f)
			end
		}
	end

	def self.remove_ds_store()
		self.remove('.DS_Store')
	end

	def self.remove_ini()
		self.remove('.picasa.ini')
	end

	def self.remove_empty_dir()
		sorted = Dir.glob(["tmp/**/*"]).sort{|a,b| b.split('/').length <=> a.split('/').length}
		sorted.each{|f|
			Dir.rmdir(f) if File::ftype(f) == "directory" and Dir.entries(f).size == 2
		}
	end
end

