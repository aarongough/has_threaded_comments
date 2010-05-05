temp = YAML.load_file(File.join(File.dirname(__FILE__), "..", "..", "generators", "install_has_threaded_comments", "templates", "threaded_comments_config.yml"))
if(!temp[RAILS_ENV].nil?)
  temp = temp[RAILS_ENV]
else
  temp = temp['production']
end
THREADED_COMMENTS_CONFIG = {}
temp.each_pair do |key, value|
  THREADED_COMMENTS_CONFIG[key.to_sym] = value.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
end
 