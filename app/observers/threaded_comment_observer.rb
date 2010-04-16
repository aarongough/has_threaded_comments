class ThreadedCommentObserver < ActiveRecord::Observer
  def after_create( comment )  
    # Send admin notification
    Notifier.deliver_new_comment_notification( comment )
    
    # Send user notifications if notifications are enabled
    # for the parent comment
    if(comment.parent_id == 0 || comment.parent_id.nil?)
      Notifier.deliver_user_comment_notification( comment.rant.email, comment ) if( comment.rant.notifications )
    else
      parent_comment = Comment.find( comment.parent_id )
      Notifier.deliver_user_comment_notification( parent_comment.email, comment ) if( parent_comment.notifications )
    end
  end
end
