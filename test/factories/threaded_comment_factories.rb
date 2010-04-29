Factory.define :threaded_comment do |t|
  t.name 'anon'
  t.email 'anon@anons.com'
  t.body 'this book rules askdjalskdjal laksjlakjd alksjd alskdjlaksjdal skdja sldkajs'
  t.threaded_comment_polymorphic_type 'Book'
  t.association :threaded_comment_polymorphic_id, :factory => :book
end