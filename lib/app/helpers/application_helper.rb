module ApplicationHelper

  def render_threaded_comments(*configuration)
    default_configuration = {
      :indent_level => 0,
      :base_indent => 0,
      :sorted => false,
      :parent_id => 0,
      :rating => true,
      :flagging => true,
      :permalinks => true,
      :flag_message => "Are you really sure you want to flag this comment? Doing so without good reason is unfair to the original author.",
      :header_separator => " | ",
      :reply_text => "Reply"
    }
    
    return unless(configuration.first.is_a(Array))
    comments = configuration.first
    if(configuration.last.is_a(Hash))
      config = default_configuration.merge(configuration.last)
    else
      config = default_configuration
    end
    
    comments = sort_comments(comments) unless(config[:sorted])
    return '' if( comments[config[:parent_id]].nil? )
    ret = ''
    this_indent = "  " * (config[:base_indent] + config[:indent_level])
    
    comments[parent_id].each do |comment|
      ret << this_indent << "<a name=\"comment_#{comment.id}\" />\n"
      ret << this_indent << "<div class=\"comment_container\">\n"
      ret << this_indent << "  <div class=\"comment_container_header\">\n"
      ret << this_indent << "    <span class=\"comment_name\">By: <strong>#{h comment.name}</strong></span>#{config[:header_separator]}\n"  
      ret << this_indent << "    <span class=\"comment_age\">#{ time_ago_in_words( comment.created_at ) } ago</span>#{config[:header_separator]}\n"
      ret << this_indent << "    <a href=\"#comment_#{comment.id}\" class=\"comment_link\">permalink</a>#{config[:header_separator] if(config[:flagging])}\n"
      if(config[:flagging])
        ret << this_indent << "    <span class=\"flag_comment_container\" id=\"flag_comment_container_#{comment.id}\">\n"
        ret << this_indent << "      #{ link_to_remote 'flag', flag_threaded_comment_path(comment), :method => :post, :confirm => config[:flag_message], :class => 'flag_comment', :update => { :success => 'flag_comment_container_' + comment.id.to_s, :failure => 'does_not_exist'}  }"
        ret << this_indent << "    </span>\n"
      end
      ret << this_indent << "  </div>\n"
      if(config[:rating])
        ret << this_indent << "  <div class=\"comment_rating\" id=\"comment_rating_#{comment.id}\" >\n"
        ret << this_indent << "    #{button_to_remote( '', upmod_threaded_comment_path(comment), :class=> "upmod_comment upmod_button", :update => 'comment_rating_' + comment.id.to_s)}"
        ret << this_indent << "    <span id=\"comment_#{comment.id}_rating\" class=\"rating_text\">#{comment.rating}</span>\n"
        ret << this_indent << "    #{button_to_remote( '', downmod_threaded_comment_path(comment), :class => "downmod_comment downmod_button", :update => 'comment_rating_' + comment.id.to_s)}"
        ret << this_indent << "  </div>\n"
      end
      ret << this_indent << "  <div class=\"comment_reply_container\" id=\"comment_reply_container_#{comment.id}\" />\n"
      ret << this_indent << "    #{link_to_remote(config[:reply_text], new_threaded_comment_path(:threaded_comment => {:parent_id => comment.id, :threaded_comment_polymorphic_id => comment.threaded_comment_polymorphic_id, :threaded_comment_polymorphic_type => comment.threaded_comment_polymorphic_type}), :class=> 'comment_reply_link', :update => 'comment_reply_container_' + comment.id.to_s)}\n"
      ret << this_indent << "  </div\>"
      ret << this_indent << "  <div class=\"comment_body\">#{simple_format(h(comment.body)) }</div>\n"
      ret << this_indent << "  <div class=\"comment_container_footer\"></div>\n"
      ret << this_indent << "</div>\n"
      
      ret << this_indent << "<div class=\"subcomment_container\">\n"
      ret << render_threaded_comments( comments, config.merge({:parent_id => comment.id, :indent_level = config[:indent_level] + 1, :sorted => true })) unless( comments[comment.id].nil? )
      ret << this_indent << "</div>\n"
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

end