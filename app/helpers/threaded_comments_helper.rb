module ThreadedCommentsHelper

  def render_threaded_comments(comments, options={})
    options = {
      :indent_level => 0,
      :base_indent => 0,
      :parent_id => 0,
      :bucketed => false
    }.merge(THREADED_COMMENTS_CONFIG[:render_threaded_comments].dup).merge(options)
    
    return '<div id="no_comments_message">' + options[:no_comments_message] + '</div>' unless(comments.length > 0)
    unless(options[:bucketed])
      comments = comments.delete_if{|comment| (comment.flags > options[:flag_threshold]) && (options[:flag_threshold] > 0) }
      comments = sort_comments(comments)
      options[:parent_id] = comments.first.parent_id if(comments.length == 1)
      comments = bucket_comments(comments)
    end
    return '' if( comments[options[:parent_id]].nil? )
    ret = ''
    this_indent = "  " * (options[:base_indent] + options[:indent_level])
    
    comments[options[:parent_id]].each do |comment|
      ret << this_indent << "<a name=\"threaded_comment_#{comment.id}\"></a>\n"
      ret << this_indent << "<div class=\"threaded_comment_container #{"fade_level_" if(comment.rating < 0)}#{comment.rating.abs.to_s if(comment.rating < 0 && comment.rating > -5)}#{"4" if(comment.rating < -4)}\" >\n"
      ret << this_indent << "  <div class=\"threaded_comment_container_header\">\n"
      if(options[:enable_rating])
        ret << this_indent << "  <div class=\"threaded_comment_rating_container\">\n"
        ret << this_indent << "    #{link_to_remote('', :url => {:controller => 'threaded_comments', :action => 'upmod', :id => comment.id}, :method => :post, :html => {:class=> 'upmod_threaded_comment'}, :update => { :success => 'threaded_comment_rating_' + comment.id.to_s })}\n"
        ret << this_indent << "    <span id=\"threaded_comment_rating_#{comment.id}\" class=\"threaded_comment_rating_text\">#{comment.rating}</span>\n"
        ret << this_indent << "    #{link_to_remote('', :url => {:controller => 'threaded_comments', :action => 'downmod', :id => comment.id}, :method => :post, :html => {:class => 'downmod_threaded_comment'}, :update => { :success => 'threaded_comment_rating_' + comment.id.to_s })}\n"
        ret << this_indent << "  </div>\n"
      end
      ret << this_indent << "    <span class=\"threaded_comment_name\">By: <strong>#{h comment.name}</strong></span>#{options[:header_separator]}\n"  
      ret << this_indent << "    <span class=\"threaded_comment_age\">#{ time_ago_in_words( comment.created_at ) } ago</span>#{options[:header_separator]}\n"
      ret << this_indent << "    <a href=\"#threaded_comment_#{comment.id}\" class=\"threaded_comment_link\">permalink</a>#{options[:header_separator] if(options[:enable_flagging])}\n"
      if(options[:enable_flagging])
        ret << this_indent << "    <span class=\"flag_threaded_comment_container\" id=\"flag_threaded_comment_container_#{comment.id}\">\n"
        ret << this_indent << "      #{link_to_remote('flag', :url => {:controller => 'threaded_comments', :action => 'flag', :id => comment.id}, :method => :post, :confirm => options[:flag_message], :update => { :success => 'flag_threaded_comment_container_' + comment.id.to_s, :failure => 'does_not_exist'})}\n"
        ret << this_indent << "    </span>\n"
      end
      ret << this_indent << "  </div>\n"
      ret << this_indent << "  <div class=\"threaded_comment_body\">#{simple_format(h(comment.body))}</div>\n"
      ret << this_indent << "  <div class=\"threaded_comment_reply_container\" id=\"threaded_comment_reply_container_#{comment.id}\" >\n"
      ret << this_indent << "    #{link_to_remote(options[:reply_link_text], :url => {:controller => 'threaded_comments', :action => 'new', :threaded_comment => {:parent_id => comment.id, :threaded_comment_polymorphic_id => comment.threaded_comment_polymorphic_id, :threaded_comment_polymorphic_type => comment.threaded_comment_polymorphic_type}}, :method => :get, :class=> 'comment_reply_link', :update => 'subcomment_container_' + comment.id.to_s, :position => :top, :success => "$('threaded_comment_reply_container_#{comment.id}').remove()")}\n"
      ret << this_indent << "  </div>\n"
      ret << this_indent << "  <div class=\"threaded_comment_container_footer\"></div>\n"
      ret << this_indent << "</div>\n"
      
      ret << this_indent << "<div class=\"subcomment_container#{ "_no_indent" if(options[:indent_level] >= options[:max_indent])}\" id=\"subcomment_container_#{comment.id}\">\n"
      ret << render_threaded_comments( comments, options.merge({:parent_id => comment.id, :indent_level => options[:indent_level] + 1, :bucketed => true })) unless( comments[comment.id].nil? )
      ret << this_indent << "</div>\n"
    end
    return ret
  end
  
  def render_comment_form(comment, options={})
    options = {
      :timestamp => Time.now.to_i.to_s,
      :comment => comment
    }.merge(THREADED_COMMENTS_CONFIG[:render_comment_form].dup).merge(options)    
    render :partial => options[:partial], :locals => options
  end
  
  private
  
    def sort_comments(comments)
      comments.sort {|a,b|
        ((b.rating.to_f + 1.0) / ((((Time.now - b.created_at) / 3600).to_f + 0.5) ** 1.25)) <=> ((a.rating.to_f + 1.0) / ((((Time.now - a.created_at) / 3600).to_f + 0.5) ** 1.25))
      }
    end
  
    def bucket_comments(comments)
      bucketed_comments = []
      comments.each do |comment|
        bucketed_comments[comment.parent_id] = [] if( bucketed_comments[comment.parent_id].nil? )
        bucketed_comments[comment.parent_id] << comment
      end
      return bucketed_comments
    end

end
