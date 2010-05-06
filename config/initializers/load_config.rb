load_path = File.expand_path("#{RAILS_ROOT}/config/threaded_comments_config.yml")
if( File.exists?(load_path))
  temp = YAML.load_file(load_path)
  if(!temp[RAILS_ENV].nil?)
    temp = temp[RAILS_ENV]
  else
    temp = temp['production']
  end
  THREADED_COMMENTS_CONFIG = {}
  temp.each_pair do |key, value|
    THREADED_COMMENTS_CONFIG[key.to_sym] = value.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
  end
end