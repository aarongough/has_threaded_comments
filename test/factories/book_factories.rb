if Factory.factories.length == 0

  Factory.define :book do |b|
    b.title 'moby dick'
    b.content  'call me ishmael...'
    b.email 'book@books.com'
  end
  
end