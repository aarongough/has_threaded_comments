class ThreadedCommentNotifier < ActionMailer::Base

  def new_comment_notification( comment )
    recipients  THREADED_COMMENTS_CONFIG[:notifications][:admin_email]
    from        THREADED_COMMENTS_CONFIG[:notifications][:system_send_email_address]
    subject     THREADED_COMMENTS_CONFIG[:notifications][:new_comment_subject]
    body        :comment => comment
  end
  
  def comment_reply_notification( user_email, comment )
    recipients  user_email
    from        THREADED_COMMENTS_CONFIG[:notifications][:system_send_email_address]
    if( comment.parent_id == 0 )
      subject   THREADED_COMMENTS_CONFIG[:notifications][:comment_reply_subject].gsub("{name}", comment.name)
    else
      body :parent_comment => ThreadedComment.find( comment.parent_id ), :comment => comment
      subject   "#{comment.name} has replied to your comment"
      return
    end
    body        :comment => comment
  end
  
  def failed_comment_creation_notification( comment )
    if(THREADED_COMMENTS_CONFIG[:notifications][:enable_comment_creation_failure_notifications])
      recipients  THREADED_COMMENTS_CONFIG[:notifications][:admin_email]
      from        THREADED_COMMENTS_CONFIG[:notifications][:system_send_email_address]
      subject     THREADED_COMMENTS_CONFIG[:notifications][:failed_comment_creation_subject]
      body        :comment => comment
    end
  end

end