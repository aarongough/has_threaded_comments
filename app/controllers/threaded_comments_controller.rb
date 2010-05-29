class ThreadedCommentsController < ActionController::Base

  before_filter :was_action_already_performed, :only => [:flag, :upmod, :downmod]

  # GET /threaded-comments
  def new
    @comment = ThreadedComment.new(params[:threaded_comment])
    @comment.name = session[:name] unless( session[:name].nil? )
    @comment.email = session[:email] unless( session[:email].nil? )
    render :layout => false
  end
  
  # GET /threaded-comments/1
  def show
    if(ThreadedComment.exists?(params[:id]))
      @comment = ThreadedComment.find(params[:id])
      render :layout => false and return
    end
    head :bad_request
  end

  # POST /threaded-comments
  def create
    head :status => :bad_request and return if check_honeypot( 'threaded_comment' )
    if( !params[:threaded_comment][:parent_id].nil? && params[:threaded_comment][:parent_id].to_i > 0 && !ThreadedComment.exists?(params[:threaded_comment][:parent_id]))
      flash[:notice] = "The comment you were trying to comment on no longer exists."
      head :status => :bad_request and return
    end
    @comment = ThreadedComment.new(params[:threaded_comment])
    if( @comment.save )
      session[:name] = @comment.name
      session[:email] = @comment.email
      render :action => 'show', :layout => false
    else
      render :action => 'new', :layout => false, :status => :bad_request
    end
  end
  
  # POST /threaded-comments/1/upmod
  def upmod
    begin
      @comment = ThreadedComment.find(params[:id])
      render :text => @comment.rating.to_s and return if(@comment.increment!('rating'))
    rescue ActiveRecord::RecordNotFound
      head :error
    end
  end
  
  # POST /threaded-comments/1/downmod
  def downmod
    begin
      @comment = ThreadedComment.find(params[:id])
      render :text => @comment.rating.to_s and return if(@comment.decrement!('rating'))
    rescue ActiveRecord::RecordNotFound
      head :error
    end
  end
  
  # POST /threaded-comments/1/flag
  def flag
    begin
      @comment = ThreadedComment.find(params[:id])
      render :text => "Thanks!" and return if(@comment.increment!('flags'))
    rescue ActiveRecord::RecordNotFound
      head :error
    end
  end
  
  # GET /threaded-comments/1/remove-notifications
  def remove_notifications
    @message = "The comment you are looking for has been removed or is incorrect." and render :action => 'remove_notifications' and return unless( ThreadedComment.exists?(params[:id]))
    @comment = ThreadedComment.find(params[:id])
    @message = "The information you provided does not match this comment." and render :action => 'remove_notifications' and return unless( params[:hash] == @comment.email_hash )
    @message = "Thank-you. Your email (#{@comment.email}) has been removed."
    @comment.notifications = false
    @comment.save
    render :action => 'remove_notifications'
  end
  
  private
  
    def was_action_already_performed
      if( session["/threaded-comments/#{params[:id]}/#{params[:action]}"].nil? && !cookies[:threaded_comment_cookies_enabled].nil? )
        session["/threaded-comments/#{params[:id]}/#{params[:action]}"] = true
      else
        head :status => :bad_request and return
      end
    end
    
    def check_honeypot( form_name, honeypot = "confirm_email" )
      unless( params[form_name][honeypot].nil? || (params[form_name][honeypot].length == 0) )
        return true
      end
      params[form_name].delete( honeypot )
      return false
    end

end