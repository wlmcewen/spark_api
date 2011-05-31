require './spec/spec_helper'

#module Faraday
#  class Adapter < Middleware
#    def save_response(env, status, body, headers = nil)
##      puts "WTF?!?!? #{env.class} #{body}"
#      env[:status] = status
#      env[:body] = body
#      env[:response_headers] = Utils::Headers.new.tap do |response_headers|
#        response_headers.update headers unless headers.nil?
#        yield response_headers if block_given?
#      end
#    end
#  end
#end

describe FlexmlsApi do
  describe "Parallel" do
    it "should run requests in parallel" do
      count = Listing.count()
      count = 0
      x = 0
      l = nil
      l2 = nil
      c = FlexmlsApi.client
#      FlexmlsApi.client.in_parallel do
#        count = Listing.count()
#        puts "COUNT #{count.inspect}"
#        l = Listing.find('1234', :_expand => "Photos")
#      end
      x.should == 2001
 #     count.should == 2001
 #     l.documents.length.should == 2
    end
    

#    it "should raise an error when one or more requests fail" do
#      stub_auth_request
#      # KABOOM!
#      stub_api_get("/listings/1234", 'listing_with_photos.json', { :_expand => "Photos" }) 
#      stub_api_get("/listings", 'errors/failure.json', { :_pagination => "count"})
#      count = 0
#      l = nil
#      FlexmlsApi.client.in_parallel do
#        count = Listing.count()
#        puts "COUNT #{count.inspect}"
#        l = Listing.find('1234', :_expand => "Photos")
    #        count.should == 2001
    #        l.photos.length.should == 5
#      end
#        count.should == 2001
#        l.photos.length.should == 5
##      end.to raise_error
#    end
    
  end
#  
#  it "should frapping work!!!!" do
#    conn = Faraday::Connection.new(:url => "http://frink.fbsdata.com") do |builder|
#      builder.use Faraday::Response::ParseJson
#      builder.use Faraday::Adapter::Typhoeus
#      builder.response :logger
#    end
#    r2 = 0
#    s = stub_request(:get, "http://frink.fbsdata.com/").to_return(:body => stub_fixture="success.json")
#    puts s.inspect
#    r2 = conn.get "/~wade/listing_with_photos.json"
#    puts r2.body
#    conn.in_parallel(Faraday::Adapter::Typhoeus.setup_parallel_manager) do
#      r2 = conn.get "/"
##      r = conn.get "/~wade/"
#      
#      puts "RESPONSEDNS #{r2.inspect}"
#    end
#    puts r2.body
#
#  end

end

