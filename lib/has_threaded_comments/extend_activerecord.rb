module ThreadedCommentsExtension
  def self.included(base)  
    base.send :extend, ClassMethods 
  end  
  
  module ClassMethods 
    # any method placed here will apply to classes, like Book 
    def has_threaded_comments(options = {})
      has_many :comments, :as => :threaded_comment_polymorphic, :class_name => "ThreadedComment"
      send :include, InstanceMethods
    end   
  end  
  
  module InstanceMethods 
    # any method placed here will apply to instaces, like @book 
  end 
end

ActiveRecord::Base.send :include, ThreadedCommentsExtension 