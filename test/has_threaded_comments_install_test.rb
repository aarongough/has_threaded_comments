require File.dirname(__FILE__) + '/test_helper.rb' 

class HasThreadedInstallTest < Test::Unit::TestCase
  
  def setup
    @message = "\n###### WARNING: Could not find '{file}'\n###### has_threaded_comments is probably not installed properly\n###### Please run ./script/generate install_has_threaded_comments to complete installation.\n"
  end
  
  def test_has_threaded_comments_static_files_installed
    install_files = [
      'config/threaded_comments_config.yml',
      'public/stylesheets/threaded_comment_styles.css'
    ]
    install_files.each do |file|
      assert File.exists?( File.join( RAILS_ROOT, file)), @message.gsub("{file}", file)
    end
  end
  
  def test_has_threaded_comments_migration_installed
    files = Dir.glob( File.join(RAILS_ROOT, 'db', 'migrate', '*')).to_s
    assert files.index("create_threaded_comments"), @message.gsub("{file}", 'create_threaded_comments migration')
  end
  
end