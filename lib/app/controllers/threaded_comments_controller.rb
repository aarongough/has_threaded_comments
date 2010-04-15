class ThreadedCommentsController < ActionController::Base

  # GET /threaded-comments
  def new
    @comment = ThreadedComment.new(params[:threaded_comment])
    @comment.name = session[:name] unless( session[:name].nil? )
    @comment.email = session[:email] unless( session[:email].nil? )
    render :layout => false
  end

  # POST /threaded-comments
  def create
    head :status => :failure and return if check_honeypot( 'comment' )
    if( params[:threaded_comment][:parent_id] != 0 && !Comment.exists?(params[:threaded_comment][:parent_id]))
      flash[:notice] = "The comment you were trying to comment on no longer exists."
      head :status => :failure and return
    end
    @comment = ThreadedComment.new(params[:threaded_comment])
    if( @comment.save )
      session[:name] = @comment.name
      session[:email] = @comment.email
      render :action => 'show', :layout => false
    else
      render :action => 'new', :layout => false, :status => :failure
    end
  end
  
  # POST /threaded-comments/1/upmod
  def upmod
    if( ThreadedComment.exists?(params[:id]) && @comment = ThreadedComment.find(params[:id]) && @comment.increment!('rating'))
      render :text => @comment.rating.to_s and return
    end
    head :bad_request
  end
  
  # POST /threaded-comments/1/downmod
  def downmod
    if( ThreadedComment.exists?(params[:id]) && @comment = ThreadedComment.find(params[:id]) && @comment.decrement!('rating'))
      render :text => @comment.rating.to_s and return
    end
    head :bad_request
  end
  
  # POST /threaded-comments/1/flag
  def flag
    if( ThreadedComment.exists?(params[:id]) && @comment = ThreadedComment.find(params[:id]) && @comment.increment!('flags'))
      render :text => "Thanks!" and return
    end
    head :bad_request
  end
  
  # GET /threaded-comments/1/remove-notifications
  def remove_notifications
    @message = "The comment you are looking for has been removed or is incorrect." and render :action => 'remove_email' and return unless( ThreadedComment.exists?(params[:id]))
    @comment = ThreadedComment.find(params[:id])
    @message = "The information you provided does not match this comment." and render :action => 'remove_email' and return unless( params[:hash] == "#{@comment.email}-#{@comment.created_at}".hash.to_s(16) )
    @message = "Thank-you. Your email (#{@comment.email}) has been removed."
    @comment.notifications = false
    @comment.save
    render :action => 'remove_email'
  end
  
  private
  
    def action_already_performed?
      if( !session["/threaded-comments/#{params[:id]}/#{params[:action]}"].nil? )
        return true
      else
        session["/threaded-comments/#{params[:id]}/#{params[:action]}"] = true
        return false
      end
    end
    
    def check_honeypot( form_name, honeypot = "confirm_email" )
      unless( params[form_name][honeypot].nil? || (params[form_name][honeypot].length == 0) )
        redirect_to "/" and return true
      end
      params[form_name].delete( honeypot )
      return false
    end

end