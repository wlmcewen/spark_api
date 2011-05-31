module FlexmlsApi
  class Response
    include PaginateResponse
    def initialize(faraday_response, request_opts, &block)
      @faraday_response = faraday_response
      @request_opts = request_opts
      @results = []
      @loaded = false
      @post_processor = block
    end
    def loaded?
      @loaded
    end
    
    def status 
      puts " FARADAY = #{@faraday_response.inspect}"
    end
    
    def process
      @loaded = true
      raise "HES DEAD JIM" unless @faraday_response.finished? # TODO FIXME
      results = @faraday_response.body.results
      paging = @faraday_response.body.pagination
      unless paging.nil?
        if @request_opts[:_pagination] == "count"
          results = [paging['TotalRows']]
        else
          results = paginate_response(results, paging)
        end
      end
      @results = @post_processor.nil? ? results : @post_processor.call(results)
    end
    def method_missing(method, *args, &block)
      unless loaded?
        raise "Request is not completed.  Is parallel mode enabled?"
      end
      if Array.method_defined?(method)
        @results.send(method, *args, &block)
      else
        super
      end
    end
  end
end
