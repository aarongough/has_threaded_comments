Factory.define :threaded_comment do |f|
  f.sequence(:name) {|n| "Test Commenter #{n}" }
  f.sequence(:email) {|n| "commenter#{n}@example.com" }
  f.sequence(:body) {|n| "This is a short example comment. This comment was produced by a factory and is number: #{n}" }
  f.threaded_comment_polymorphic_type 'Book'
  f.threaded_comment_polymorphic_id 1
end