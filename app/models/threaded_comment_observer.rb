class ThreadedCommentObserver < ActiveRecord::Observer
  def after_create( threaded_comment )  
    # Send admin notification
    ThreadedCommentNotifier.deliver_new_comment_notification( threaded_comment )
    
    # Send user notifications if notifications are enabled
    # for the parent comment
    if(threaded_comment.parent_id == 0 || threaded_comment.parent_id.nil?)
      if( threaded_comment.threaded_comment_polymorphic.respond_to?(:notifications) && threaded_comment.threaded_comment_polymorphic.respond_to?(:email))
        ThreadedCommentNotifier.deliver_comment_reply_notification( threaded_comment.threaded_comment_polymorphic.email, threaded_comment ) if( threaded_comment.threaded_comment_polymorphic.notifications )
      end
    else
      parent_comment = ThreadedComment.find( threaded_comment.parent_id )
      ThreadedCommentNotifier.deliver_comment_reply_notification( parent_comment.email, threaded_comment ) if( parent_comment.notifications )
    end
  end
end
