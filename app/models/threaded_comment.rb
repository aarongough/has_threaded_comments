class ThreadedComment < ActiveRecord::Base

  require 'digest/md5'

  validates_presence_of   :threaded_comment_polymorphic_id, :threaded_comment_polymorphic_type, :parent_id
  validates_length_of     :name, :within => 2..18
  validates_length_of     :body, :within => 30..2000
  validates_text_content  :body if( ActiveRecord::Base.respond_to?('validates_text_content'))
  validates_length_of     :email, :minimum => 6
  validates_format_of     :email, :with => /.*@.*\./

  belongs_to :threaded_comment_polymorphic, :polymorphic => true
  alias owner_item threaded_comment_polymorphic
  
  before_validation   :assign_owner_info_to_nested_comment
  
  attr_accessible :name, :body, :email, :parent_id, :threaded_comment_polymorphic_id, :threaded_comment_polymorphic_type
  
  def assign_owner_info_to_nested_comment
    unless( self[:parent_id].nil? || self[:parent_id] == 0 )
      parentComment = ThreadedComment.find(self[:parent_id])
      self[:threaded_comment_polymorphic_id] = parentComment.threaded_comment_polymorphic_id
      self[:threaded_comment_polymorphic_type] = parentComment.threaded_comment_polymorphic_type
    end
    self[:parent_id] = 0 if( self[:parent_id].nil? )
  end
  
  def email_hash
    return Digest::MD5.hexdigest("#{self.email}-#{self.created_at}")
  end

end