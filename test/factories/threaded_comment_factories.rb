Factory.define :threaded_comment do |f|
  f.sequence(:id) {|n| n }
  f.sequence(:name) {|n| "TestCommenter#{n}" }
  f.sequence(:email) {|n| "commenter#{n}@example.com" }
  f.sequence(:body) {|n| "This is a short example comment. This comment was produced by a factory and is number: #{n}" }
  f.parent_id 0
  f.sequence(:rating) {|n| n }
  f.threaded_comment_polymorphic_type 'Book'
  f.threaded_comment_polymorphic_id 1
  f.created_at Time.now
end