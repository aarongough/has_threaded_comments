module ActionViewStubs

  def link_to_remote(*args)
    if( args.last.is_a?(Hash))
      url = args.last[:url]
      url = "/#{url[:controller]}/#{url[:action]}/#{url[:id]}"
    end
    if( args.first.is_a?(String))
      "<a href=\"#{url}\">#{args.first}</a>"
    else
      ""
    end
  end
  
  def time_ago_in_words(*args)
    args.first.to_s
  end
  
  def render(options)
    options
  end

end