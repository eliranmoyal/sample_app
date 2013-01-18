require 'spec_helper'

describe UsersController do
	render_views

	describe "GET 'show'" do
		
		before(:each) do
			@user = FactoryGirl.create(:user)
		end

		it "should be seccessful" do
			get 'show', :id => @user
			response.should be_success		
		end

		it "should return the right user" do
			get 'show', :id => @user
			assigns(:user) == @user
		end
	end

	describe "GET 'new'" do
		it "returns http success" do
			get 'new'
			response.should be_success
		end

		it "should have the right title" do
			get 'new'
			response.should have_selector('title' , :content => "Sign up" )
		end
	end

end
