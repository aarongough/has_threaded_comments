class ThreadedCommentNotifier < ActionMailer::Base

  def new_comment_notification( comment )
    recipients  THREADED_COMMENTS_CONFIG["admin_email"]
    from        THREADED_COMMENTS_CONFIG["system_send_email_address"]
    subject     THREADED_COMMENTS_CONFIG["new_comment_subject"]
    body        :comment => comment
  end
  
  def comment_reply_notification( user_email, comment)
    recipients  user_email
    from        APP_CONFIG["system_send_email_address"]
    if( comment.parent_id > 0 )
      body :parent_comment => Comment.find( comment.parent_id ), :comment => comment
      subject   THREADED_COMMENTS_CONFIG["comment_reply_subject"].gsub("{name}", comment.name)
      return
    end
    body        :comment => comment
  end
  
  def failed_comment_creation_notification( comment )
    if(THREADED_COMMENTS_CONFIG["enable_comment_creation_failure_notifications"])
      recipients  THREADED_COMMENTS_CONFIG["admin_email"]
      from        THREADED_COMMENTS_CONFIG["system_send_email_address"]
      subject     THREADED_COMMENTS_CONFIG["failed_comment_creation_subject"]
      body        :comment => comment
    end
  end

end