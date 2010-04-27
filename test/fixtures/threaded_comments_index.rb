module ThreadedCommentsIndex

  # get /threaded-comments
  # this is just a temporary pass-through to allow testing of comment rendering
  def index
    @comments = ThreadedComment.all
    render :file => File.join( RAILS_ROOT, 'vendor', 'plugins', 'has_threaded_comments', 'test', 'fixtures', 'index.erb')
  end

end