class ThreadedComment < ActiveRecord::Base

  belongs_to :threaded_comment_polymorphic, :polymorphic => true

end