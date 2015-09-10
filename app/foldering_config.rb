require 'logger'
require 'yaml'

class FolderingConfig
  @@conf = YAML.load_file('config.yml')
  def initialize(mode)
    # File::expand_path seems to remove last slash
    log_dir = File::expand_path(project_root.to_s + "/log") + "/"
    log_path = log_dir + "app.log"
    if File::exist?(log_path)
      timestump = File::stat(log_path).mtime.strftime("%Y%m%d-%H%M%S")
      File.rename(log_path, log_dir + timestump.to_s + ".log")
    end
    $logger = Logger.new(log_path)
    $logger.level = @@conf["log_level"]
  end

  def project_root
    @@conf["project_root_dir"]
  end
end
