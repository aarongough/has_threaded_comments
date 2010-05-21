class InstallHasThreadedCommentsGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file "threaded_comments_config.yml", "config/threaded_comments_config.yml"
      m.directory "public/stylesheets"
      m.file "threaded_comment_styles.css", "public/stylesheets/threaded_comment_styles.css"
      m.directory "public/has-threaded-comments-images"
      m.file "downmod-arrow.gif", "public/has-threaded-comments-images/downmod-arrow.gif"
      m.file "upmod-arrow.gif", "public/has-threaded-comments-images/upmod-arrow.gif"
      m.file "ajax-loader.gif", "public/has-threaded-comments-images/ajax-loader.gif"
      m.migration_template "create_threaded_comments.rb", "db/migrate"
    end
  end
  
  def file_name
    "create_threaded_comments"
  end
end
