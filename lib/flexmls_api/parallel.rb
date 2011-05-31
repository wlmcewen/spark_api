
#  # Take advantage of faraday's parallel request support
#  define_method "test_#{adapter}_async_requests_uses_parallel_manager_to_run_multiple_json_requests" do
#    resp1, resp2 = nil, nil
#  
#    connection = create_connection(adapter)
#    adapter    = real_adapter_for(adapter)
#  
#    connection.in_parallel(adapter.setup_parallel_manager) do
#      resp1 = connection.get('json')
#      resp2 = connection.get('json')
#      if adapter.supports_parallel_requests?
#        assert connection.in_parallel?
#        assert_nil resp1.body
#        assert_nil resp2.body
#      end
#    end
#    assert !connection.in_parallel?
#    assert_equal '[1,2,3]', resp1.body
#    assert_equal '[1,2,3]', resp2.body
#  end
module FlexmlsApi
  module Parallel
    
    def in_parallel()
      block = block_given? ? Proc.new : nil
      puts "BLOCK #{block.inspect}"
      @is_in_parallel = true
      @parallel_responses = []
      puts "RUNNING BLOCK>"
      connection.in_parallel(Faraday::Adapter::Typhoeus.setup_parallel_manager, &block)
      puts "RUNNING BLOCK<"
      @parallel_responses.each { |p| p.status }
    ensure
      @is_in_parallel = false
      @parallel_responses = []
    end
    def in_parallel?
      @is_in_parallel
    end
    
  end

  
end

