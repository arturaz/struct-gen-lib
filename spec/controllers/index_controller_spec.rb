require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "rendering png", :shared => true do
  it "should be successful" do
    send @method, @action, @url_params
    response.should be_success
  end
  
  it "should have PNG header" do
    send @method, @action, @url_params
    response.headers['type'].should include("image/png")
  end
  
  it "should render png" do
    send @method, @action, @url_params
    response.body.should_not be_blank
  end
end

describe IndexController do
  integrate_views
  
  describe "#index" do
    before(:each) do
      @action = 'index'
      @url_params = {}
    end
    
    describe "GET" do
      before(:each) do
        @method = 'get'
      end
      
      it "should have @structurograme" do
        get @action, @url_params
        assigns[:structurograme].should_not be_blank
      end
      
      it "should be successful" do
        get @action, @url_params
        response.should be_success
      end
      
      describe "template" do
        before(:each) do
          get @action, @url_params || {}
        end
        
        it "should have form" do
          response.should have_tag("form[method=post]")
        end
        
        it "should have input for xml" do
          response.should have_tag("textarea[name=?]", "structurograme[xml]")
        end
        
        it "should have input for size" do
          response.should have_tag("input[type=text][name=?]", 
            "structurograme[size]")
        end
        
        it "should have input for width" do
          response.should have_tag("input[type=text][name=?]", 
            "structurograme[width]")
        end
        
        it "should have submit button" do
          response.should have_tag("input[type=submit]")
        end
      end
    end
    
    describe "POST" do
      before(:each) do
        @method = 'post'
        @url_params.merge!(:structurograme => {
          :xml => "<block>test</block>",
          :size => 12,
          :width => 800
        })
      end
      
      it_should_behave_like "rendering png"
      
      describe "xhr" do
        it "should set session[:params]" do
          xhr :post, @action, @url_params
          session[:params].should_not be_blank
        end
        
        it "should render json" do
          controller.should_receive(:render).with(:json => anything)
          xhr :post, @action, @url_params
        end
        
        it "should have image source" do
          xhr :post, @action, @url_params
          response.body.should include('"image_source":')
        end
      end
      
      describe "failure" do
        before(:each) do
          @url_params.merge!(:structurograme => nil)
        end
        
        it "should be successful" do
          post @action, @url_params
          response.should be_success
        end
        
        it "should have @structurograme.errors not blank" do
          post @action, @url_params
          assigns[:structurograme].errors.should_not be_blank
        end
        
        describe "xhr" do
          it "should set not session[:params]" do
            xhr :post, @action, @url_params
            session[:params].should be_blank
          end

          it "should have errors in response" do
            xhr :post, @action, @url_params
            response.body.should include('"errors":')
          end
        end
      end
    end
  end
  
  describe "#get_structurograme" do
    before(:each) do
      @action = 'get_structurograme'
      @url_params = {}
    end
    
    describe "GET" do
      before(:each) do
        @method = 'get'
        session[:params] = {:width => 800, :size => 12, 
          :xml => "<block>TEST</block>"}
      end
      
      it "should be successful" do
        get @action, @url_params
        response.should be_success
      end
      
      it_should_behave_like "rendering png"
    end
  end
end
