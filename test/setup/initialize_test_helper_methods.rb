# Test helper method for easily creating a complex threaded_comment
# structure for use in other tests. Returns an array of comments
# the same way that ACtiveRecord would.

def create_complex_thread(length=100)
  comments = []
  length.times do
    comments << parent_comment = Factory.build(:threaded_comment)
    3.times do
      comments << subcomment1 = Factory.build(:threaded_comment, :parent_id => parent_comment.id)
      2.times do
        comments << subcomment2 = Factory.build(:threaded_comment, :parent_id => subcomment1.id)
        2.times do
          comments << subcomment3 = Factory.build(:threaded_comment, :parent_id => subcomment2.id)
        end
      end
    end
  end
  comments
end

# Test helper method for temporarily changing the value of a 
# configuration option. Eg:
# 
#   change_config_option(:render_threaded_comments, :enable_flagging, false) do
#     # some code that requires flagging to be disabled by default
#   end

def change_config_option(namespace, key, value, &block)
  old_config = THREADED_COMMENTS_CONFIG.dup
  old_stderr = $stderr
  $stderr = StringIO.new
  THREADED_COMMENTS_CONFIG[namespace][key] = value
  $stderr = old_stderr
  yield block
ensure
  $stderr = StringIO.new
  Kernel.const_set('THREADED_COMMENTS_CONFIG', old_config)
  $stderr = old_stderr
end