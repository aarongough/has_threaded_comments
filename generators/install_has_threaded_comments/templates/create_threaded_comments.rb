class CreateThreadedComments < ActiveRecord::Migration
  def self.up
    create_table :threaded_comments, :force => true do |t|
      t.string   :name,          :default => ""
      t.text     :body
      t.integer  :rating,        :default => 0
      t.integer  :flags,         :default => 0
      t.integer  :parent_id,     :default => 0
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :email,         :default => ""
      t.boolean  :notifications, :default => true
      
      t.integer  :threaded_comment_polymorphic_id
      t.string   :threaded_comment_polymorphic_type
    end
  end
  
  def self.down
    drop_table :threaded_comments
  end
end