require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))
require 'rails_generator' 
require 'rails_generator/scripts/generate' 

class GeneratorTest < Test::Unit::TestCase 

  def setup 
    FileUtils.mkdir_p(fake_rails_root)
    FileUtils.mkdir_p(File.join(fake_rails_root, 'config')) 
    FileUtils.mkdir_p(File.join(fake_rails_root, 'db', 'migrate'))
    FileUtils.mkdir_p(File.join(fake_rails_root, 'public', 'stylesheets'))
    FileUtils.mkdir_p(File.join(fake_rails_root, 'public', 'has-threaded-comments-images')) 
  end  
  
  def teardown 
    FileUtils.rm_r(fake_rails_root)  
  end  
  
  def test_generates_threaded_comments_config
    @original_files = file_list('config')
    Rails::Generator::Scripts::Generate.new.run(["install_has_threaded_comments"], :destination => fake_rails_root, :quiet => true)  
    new_file = (file_list('config') - @original_files).first 
    assert_equal "threaded_comments_config.yml", File.basename(new_file)  
  end
  
  def test_generates_threaded_comments_migration
    @original_files = file_list('db', 'migrate')
    Rails::Generator::Scripts::Generate.new.run(["install_has_threaded_comments"], :destination => fake_rails_root, :quiet => true)  
    new_file = (file_list('db', 'migrate') - @original_files).first 
    assert new_file.index('create_threaded_comments')  
  end
  
  def test_generates_threaded_comments_styles_stylesheet
    @original_files = file_list('public', 'stylesheets')
    Rails::Generator::Scripts::Generate.new.run(["install_has_threaded_comments"], :destination => fake_rails_root, :quiet => true)  
    new_file = (file_list('public', 'stylesheets') - @original_files).first 
    assert_equal "threaded_comment_styles.css", File.basename(new_file)    
  end
  
  def test_adds_images
    @original_files = file_list('public', 'has-threaded-comments-images')
    Rails::Generator::Scripts::Generate.new.run(["install_has_threaded_comments"], :destination => fake_rails_root, :quiet => true)  
    new_files = (file_list('public', 'has-threaded-comments-images') - @original_files) 
    assert_equal 3, new_files.length
    new_files.sort!
    assert_equal "ajax-loader.gif", File.basename(new_files.first)
    assert_equal "downmod-arrow.gif", File.basename(new_files[1])
    assert_equal "upmod-arrow.gif", File.basename(new_files.last)
  end
  
  private 
  
    def fake_rails_root 
      File.join(File.dirname(__FILE__), 'rails_root')  
    end  
    
    def file_list(*path)
      Dir.glob(File.join(fake_rails_root, path, '*'))  
    end 
    
end 