class Deleter

	# Only for *nix
	def self.remove_ds_store()
		system('find tmp -name .DS_Store | xargs rm')
	end

	def self.remove_ini()
		system('find tmp -name .picasa.ini | xargs rm')
	end

	def self.remove_empty_dir()
		sorted = Dir.glob(["tmp/**/*"]).sort{|a,b| b.split('/').length <=> a.split('/').length}
		sorted.each{|f|
			Dir.rmdir(f) if File::ftype(f) == "directory" and Dir.entries(f).size == 2
		}
	end
end

