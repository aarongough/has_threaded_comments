module ThreadedCommentsHelper

  def render_threaded_comments(comments, options={})
    options = {
      :indent_level => 0,
      :base_indent => 0,
      :parent_id => 0,
      :max_indent => 1,
      :rating => true,
      :sorted => false,
      :flagging => true,
      :permalinks => true,
      :flag_message => "Are you really sure you want to flag this comment?",
      :no_comments_message => "There aren't any comments yet, be the first to comment!",
      :header_separator => " - ",
      :reply_text => "Reply"
    }.merge(options).merge(THREADED_COMMENTS_CONFIG.map { |k,v| { k.to_sym => v }}[0])
    
    return options[:no_comments_message] unless(comments.length > 0)
    unless(options[:sorted])
      comments = comments.delete_if{|comment| (comment.flags > THREADED_COMMENTS_CONFIG['flag_threshold']) && (THREADED_COMMENTS_CONFIG['flag_threshold'] > 0) }
      options[:parent_id] = comments.first.parent_id if(comments.length == 1)
      comments = sort_comments(comments)
    end
    return '' if( comments[options[:parent_id]].nil? )
    ret = ''
    this_indent = "  " * (options[:base_indent] + options[:indent_level])
    
    comments[options[:parent_id]].each do |comment|
      ret << this_indent << "<a name=\"threaded_comment_#{comment.id}\"></a>\n"
      ret << this_indent << "<div class=\"threaded_comment_container\" >\n"
      ret << this_indent << "  <div class=\"threaded_comment_container_header\">\n"
      ret << this_indent << "    <span class=\"threaded_comment_name\">By: <strong>#{h comment.name}</strong></span>#{options[:header_separator]}\n"  
      ret << this_indent << "    <span class=\"threaded_comment_age\">#{ time_ago_in_words( comment.created_at ) } ago</span>#{options[:header_separator]}\n"
      ret << this_indent << "    <a href=\"#threaded_comment_#{comment.id}\" class=\"threaded_comment_link\">permalink</a>#{options[:header_separator] if(options[:flagging])}\n"
      if(options[:flagging])
        ret << this_indent << "    <span class=\"flag_threaded_comment_container\" id=\"flag_threaded_comment_container_#{comment.id}\">\n"
        ret << this_indent << "      #{ link_to_remote 'flag', :url => {:controller => 'threaded_comments', :action => 'flag', :id => comment.id}, :method => :post, :confirm => options[:flag_message], :update => { :success => 'flag_threaded_comment_container_' + comment.id.to_s, :failure => 'does_not_exist'}  }\n"
        ret << this_indent << "    </span>\n"
      end
      ret << this_indent << "  </div>\n"
      if(options[:rating])
        ret << this_indent << "  <div class=\"threaded_comment_rating_container\">\n"
        ret << this_indent << "    #{link_to_remote( '', :url => {:controller => 'threaded_comments', :action => 'upmod', :id => comment.id}, :method => :post, :html => {:class=> 'upmod_threaded_comment'}, :update => { :success => 'threaded_comment_rating_' + comment.id.to_s })}\n"
        ret << this_indent << "    <span id=\"threaded_comment_rating_#{comment.id}\" class=\"threaded_comment_rating_text\">#{comment.rating}</span>\n"
        ret << this_indent << "    #{link_to_remote( '', :url => {:controller => 'threaded_comments', :action => 'downmod', :id => comment.id}, :method => :post, :html => {:class => 'downmod_threaded_comment'}, :update => { :success => 'threaded_comment_rating_' + comment.id.to_s })}\n"
        ret << this_indent << "  </div>\n"
      end
      ret << this_indent << "  <div class=\"threaded_comment_body\">#{simple_format(h(comment.body)) }</div>\n"
      ret << this_indent << "  <div class=\"threaded_comment_reply_container\" >\n"
      ret << this_indent << "    #{link_to_remote(options[:reply_text], :url => {:controller => 'threaded_comments', :action => 'new', :threaded_comment => {:parent_id => comment.id, :threaded_comment_polymorphic_id => comment.threaded_comment_polymorphic_id, :threaded_comment_polymorphic_type => comment.threaded_comment_polymorphic_type}}, :method => :get, :class=> 'comment_reply_link', :update => 'subcomment_container_' + comment.id.to_s, :position => :top)}\n"
      ret << this_indent << "  </div>\n"
      ret << this_indent << "  <div class=\"threaded_comment_container_footer\"></div>\n"
      ret << this_indent << "</div>\n"
      
      if options[:max_indent] <= options[:indent_level] or !comments.first #used to distinguish ajax/html responses
        ret << this_indent << "<div class=\"subcomment_container_no_indent\" id=\"subcomment_container_#{comment.id}\">\n"
        ret << render_threaded_comments( comments, options.merge({:parent_id => comment.id, :indent_level => options[:indent_level] + 1, :sorted => true })) unless( comments[comment.id].nil? )
        ret << this_indent << "</div>\n"
      else
        ret << this_indent << "<div class=\"subcomment_container\" id=\"subcomment_container_#{comment.id}\">\n"
        ret << render_threaded_comments( comments, options.merge({:parent_id => comment.id, :indent_level => options[:indent_level] + 1, :sorted => true })) unless( comments[comment.id].nil? )
        ret << this_indent << "</div>\n"
      end
    end
    return ret
  end
  
  def sort_comments( comments )
    bucketed_comments = []
    comments.each do |comment|
      bucketed_comments[comment.parent_id] = [] if( bucketed_comments[comment.parent_id].nil? )
      bucketed_comments[comment.parent_id] << comment
    end
    return bucketed_comments
  end
  
  def render_comment_form(comment, options={})
    options = {
      :partial => 'threaded_comments/comment_form',
      :name_label => '<strong>Name</strong><br />',
      :email_label => '<strong>Email</strong> (so we can notify you when someone replies to your comment)<br />You may opt-out at any time. Your email address will not be made public or shared in any way. <br />',
      :body_label => '2000 characters max. HTML is not allowed.<br />Eloquent writing, correct spelling and proper punctuation are strongly encouraged.<br />',
      :submit_title => 'Add Comment',
      :honeypot_name => 'confirm_email',
      :timestamp => Time.now.to_i.to_s,
      :comment => comment
    }.merge(options)    
    render :partial => options[:partial], :locals => options
  end

end
