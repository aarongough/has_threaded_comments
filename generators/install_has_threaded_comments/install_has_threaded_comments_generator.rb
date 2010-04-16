class InstallHasThreadedCommentsGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file "threaded_comments_config.yml", "config/threaded_comments_config.yml"
      m.file "threaded_comment_styles.css", "public/stylesheets/threaded_comment_styles.css"
      m.migration_template "create_threaded_comments.rb", "db/migrate"
    end
  end
  
  def file_name
    "create_threaded_comments"
  end
end
