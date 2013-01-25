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

		it "should have the right title" do
			get 'show', :id => @user
			response.should have_selector('title',:content => @user.name)
		end

		it "should have name in header" do
			get 'show', :id => @user
			response.should have_selector('h1', :content =>@user.name)
		end

		it "should have image tag in header" do
			get 'show', :id => @user
			response.should have_selector('h1>img', :class =>"gravatar")
		end

		it "should have correct url  in table" do
			get 'show', :id => @user
			response.should have_selector('td>a', :content => user_path(@user),
				:href => user_path(@user))
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

	describe "POST 'create'" do

		describe "failure" do

			before(:each) do
				@attr = {
					:name => "" ,
					:email => "" ,
					:password => "",
					:password_confirmation => ""
				}
			end

			it "should have the right title" do
				post 'create' , :user => @attr
				response.should have_selector('title' , :content => "Sign up")
			end

			it "should render new page" do
				post 'create' , :user => @attr
				response.should render_template('new')
			end

			it "should not create a user" do
				lambda do
					post 'create' , :user => @attr
				end.should_not change(User,:count)
			end
		end

		describe "success" do

			before(:each) do
				@attr = {
					:name => "eliran" ,
					:email => "eliran@gmail.com" ,
					:password => "password",
					:password_confirmation => "password"
				}
			end

			it "should create a user" do
				lambda do
					post 'create' , :user =>@attr
				end.should change(User,:count).by(1)
			end
			
			it "should redirect to user page" do
				post 'create' , :user =>@attr
				response.should redirect_to(user_path(assigns(:user)))
			end
			
		end
		
	end

end
