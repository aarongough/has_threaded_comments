module DelayedJobStubs
  
  def stub_send_later
    $delayed_jobs ||= []
    Object.class_eval <<-EOD
      def send_later(*args)
        $delayed_jobs << 'new_delayed_job'
      end
    EOD
    yield
    Object.send(:remove_method, :send_later)
  end
  
end