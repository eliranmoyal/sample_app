require 'spec_helper'

describe PagesController do
 render_views
 

 before(:each) do
  @baseTitle = 'Ruby Sample App'
 end

  describe "GET 'home'" do
    it "returns http success" do
      get 'home'
      response.should be_success
    end
    
    it "should have good title" do
      get 'home'
      response.should have_selector("title", :content => "#{@baseTitle} | Home")
    end
    
      it "should not have blank body" do
      get 'home'
      response.body.should_not =~ /<body>\s*<\/body>/
    end
  end

  describe "GET 'contact'" do
    it "returns http success" do
      get 'contact'
      response.should be_success
    end
     it "should have good title" do
      get 'contact'
      response.should have_selector("title", :content => "#{@baseTitle} | Contact")
    end
  end
  
    describe "GET 'about'" do
    it "returns http success" do
      get 'about'
      response.should be_success
    end
    
     it "should have good title" do
      get 'about'
      response.should have_selector("title", :content => "#{@baseTitle} | About")
    end
  end

end
