require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))
require 'benchmark'

class HelperPerformanceTest < ActionView::TestCase
  
  include ThreadedCommentsHelper
  include ActionViewStubs
  
  test "render_threaded_comments performance" do
    puts "\n\nBenchmarking: render_threaded_comments"
    complex_thread = create_complex_thread(50)
    simple_thread = []
    complex_thread.length.times do
      simple_thread << Factory.build(:threaded_comment)
    end
    Benchmark.bmbm do |b|
      b.report("Simple thread with #{simple_thread.length} comments") {render_threaded_comments(simple_thread)}
      b.report("Complex thread with #{complex_thread.length} comments") {render_threaded_comments(complex_thread)}
    end
  end
  
end