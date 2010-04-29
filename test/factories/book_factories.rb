Factory.define :book do |f|
  f.sequence(:title) {|n| "Book #{n}" }
  f.content  'Call me ishmael...'
  f.sequence(:email) {|n| "book#{n}@example.com" }
end