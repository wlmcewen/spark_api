require 'cgi'

module FlexmlsApi
  # HTTP request wrapper.  Performs all the api session mumbo jumbo so that the models don't have to.
  module Request
    include PaginateResponse
    include Parallel
    # Perform an HTTP GET request
    # 
    # * path - Path of an api resource, excluding version and endpoint (domain) information
    # * options - Resource request options as specified being supported via and api resource
    # :returns:
    #   Hash of the json results as documented in the api.
    # :raises:
    #   FlexmlsApi::ClientError or subclass if the request failed.
    def get(path, options={}, &block)
      request(:get, path, nil, options, &block)
    end

    # Perform an HTTP POST request
    # 
    # * path - Path of an api resource, excluding version and endpoint (domain) information
    # * body - Hash for post body data
    # * options - Resource request options as specified being supported via and api resource
    # :returns:
    #   Hash of the json results as documented in the api.
    # :raises:
    #   FlexmlsApi::ClientError or subclass if the request failed.
    def post(path, body={}, options={}, &block)
      request(:post, path, body, options, &block)
    end

    # Perform an HTTP PUT request
    # 
    # * path - Path of an api resource, excluding version and endpoint (domain) information
    # * body - Hash for post body data
    # * options - Resource request options as specified being supported via and api resource
    # :returns:
    #   Hash of the json results as documented in the api.
    # :raises:
    #   FlexmlsApi::ClientError or subclass if the request failed.
    def put(path, body={}, options={}, &block)
      request(:put, path, body, options, &block)
    end

    # Perform an HTTP DELETE request
    # 
    # * path - Path of an api resource, excluding version and endpoint (domain) information
    # * options - Resource request options as specified being supported via and api resource
    # :returns:
    #   Hash of the json results as documented in the api.
    # :raises:
    #   FlexmlsApi::ClientError or subclass if the request failed.
    def delete(path, options={}, &block)
      request(:delete, path, nil, options, &block)
    end
    
    private

    # Perform an HTTP request (no data)
    def request(method, path, body, options, &block)
      unless authenticated?
        authenticate
      end
      attempts = 0
      begin
        request_opts = {}
        request_opts.merge!(options)
        post_data = body.nil? ? nil : {"D" => body }.to_json
        request_path = "/#{version}#{path}"
        start_time = Time.now
        FlexmlsApi.logger.debug("#{method.to_s.upcase} Request:  #{request_path}")
        if post_data.nil?
          response = authenticator.request(method, request_path, nil, request_opts)
        else
          FlexmlsApi.logger.debug("#{method.to_s.upcase} Data:   #{post_data}")
          response = authenticator.request(method, request_path, post_data, request_opts)
        end
        request_time = Time.now - start_time
        FlexmlsApi.logger.info("[#{(request_time * 1000).to_i}ms] Api: #{method.to_s.upcase} #{request_path}")
      rescue PermissionDenied => e
        if(ResponseCodes::SESSION_TOKEN_EXPIRED == e.code)
          unless (attempts +=1) > 1
            FlexmlsApi.logger.debug("Retrying authentication")
            authenticate
            retry
          end
        end
        # No luck authenticating... KABOOM!
        FlexmlsApi.logger.error("Authentication failed or server is sending us expired tokens, nothing we can do here.")
        raise
      end
      if in_parallel?
        @parallel_responses << Response.new(response, request_opts, &block)
      else
        # process immediately
        Response.new(response, request_opts, &block).process
      end
      
    end
    
  end
 
  # All known response codes listed in the API
  module ResponseCodes
    NOT_FOUND = 404
    METHOD_NOT_ALLOWED = 405
    INVALID_KEY = 1000
    DISABLED_KEY = 1010
    API_USER_REQUIRED = 1015
    SESSION_TOKEN_EXPIRED = 1020
    SSL_REQUIRED = 1030
    INVALID_JSON = 1035
    INVALID_FIELD = 1040
    MISSING_PARAMETER = 1050
    INVALID_PARAMETER = 1053
    CONFLICTING_DATA = 1055
    NOT_AVAILABLE= 1500
    RATE_LIMIT_EXCEEDED = 1550
  end
  
  # Errors built from API responses
  class InvalidResponse < StandardError; end
  class ClientError < StandardError
    attr_reader :code, :status
    def initialize (code, status)
      @code = code
      @status = status
    end
  end
  class NotFound < ClientError; end
  class PermissionDenied < ClientError; end
  class NotAllowed < ClientError; end
  class BadResourceRequest < ClientError; end
  
  # Nice and handy class wrapper for the api response hash
  class ApiResponse
    attr_accessor :code, :message, :results, :success, :pagination
    def initialize(d)
      begin
        hash = d["D"]
        if hash.nil? || hash.empty?
          raise InvalidResponse, "The server response could not be understood"
        end
        self.message  = hash["Message"]
        self.code     = hash["Code"]
        self.results  = hash["Results"]
        self.success  = hash["Success"]
        self.pagination = hash["Pagination"]
      rescue Exception => e
        FlexmlsApi.logger.error "Unable to understand the response! #{d}"
        raise
      end
    end
    def success?
      @success
    end
  end

end
