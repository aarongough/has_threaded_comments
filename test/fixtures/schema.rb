# Redirect STDOUT so that the migration info is not echoed to the shell
original_stdout = $stdout
$stdout = File.open("/dev/null", "w")

ActiveRecord::Schema.define(:version => 0) do
  create_table :books, :force => true do  |t| 
    t.string    :title
    t.text      :content
    t.string    :email
    t.boolean   :notifications, :default => true
  end
  
  create_table :threaded_comments, :force => true do |t|
    t.string      :name
    t.text        :body
    t.integer     :rating, :default => 0
    t.integer     :flags, :default => 0
    t.string      :email
    t.boolean     :notifications, :default => true
    t.integer     :parent_id, :default => 0    
    t.integer     :threaded_comment_polymorphic_id
    t.string      :threaded_comment_polymorphic_type
    t.timestamps
  end
end

# Restore STDOUT so that the rest of the tests can echo to the shell as usual
$stdout = original_stdout