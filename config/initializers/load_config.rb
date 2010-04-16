load_path = "#{RAILS_ROOT}/config/threaded_comments_config.yml"
if( File.exists?(load_path))
  THREADED_COMMENTS_CONFIG = YAML.load_file(load_path)[RAILS_ENV]
end