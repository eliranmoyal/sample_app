  require 'spec_helper'

  describe PagesController do
   render_views
   

   before(:each) do
    @baseTitle = 'Eliran Twitter'
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

    describe "when signed in" do
      before(:each) do
        @user = test_sign_in FactoryGirl.create(:user)
        @follower = FactoryGirl.create(:user,:email => FactoryGirl.generate(:email))
        @follower.follow!(@user)
      end

      it "should have following and follower correct number" do
        get :home
        response.should have_selector('a' , :href => following_user_path(@user),
                                            :content => "0 following")
        response.should have_selector('a' , :href => followers_user_path(@user),
                                            :content => "1 follower")
        
      end
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


  describe "GET 'help'" do
    it "returns http success" do
      get 'help'
      response.should be_success
    end
    
    it "should have good title" do
      get 'help'
      response.should have_selector("title", :content => "#{@baseTitle} | Help")
    end
  end

end
