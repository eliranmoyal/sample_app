require 'spec_helper'

describe UsersController do
	render_views

	describe "GET 'index'" do
		describe "for not signed-in" do
			it "should deny access" do
				get :index
				response.should redirect_to(signin_path)
			end
		end
		describe "when signed-in" do
			
			before(:each) do
				@user =  FactoryGirl.create(:user)
				test_sign_in @user
				FactoryGirl.create(:user , :email =>"someother@example.com")

				30.times do
					FactoryGirl.create(:user , :email => FactoryGirl.generate(:email))
				end

			end

			it "should return success" do
					get :index
					response.should be_success
			end

			it "should have the right title" do
				get :index
				response.should have_selector('title',:content => "All users")
			end

			it "should have li for each user" do
				get :index 
				User.all.each do |user|
					response.should have_selector('li',:content => user.name)
				end
			end

			it "should paginate users" do
				get :index
				response.should have_selector('div.pagination')
				response.should have_selector('span.disabled', :content => "Previous")
				response.should have_selector('a',:href => "/users?page=2" , :content =>"2")
				response.should have_selector('a',:href => "/users?page=2" , :content =>"Next")
			end

			it "should have delete link for admin" do
				@user.toggle!(:admin)
				other_user = User.all.second
				get :index
				response.should have_selector('a',:href => user_path(other_user) , 
					:content => "delete" )
			end

			it "should have delete link for admin" do
				other_user = User.all.second
				get :index
				response.should_not have_selector('a',:href => user_path(other_user) , 
					:content => "delete" )
			end

		end
	end
	describe "GET 'show'" do
		
		before(:each) do
			@user = FactoryGirl.create(:user)
		end

		it "should be successful" do
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

			it "should have a welcome message" do
				post 'create' , :user =>@attr
				flash[:success] =~ /welcome/i				
			end

			it "should be sign in" do
				post 'create' , :user => @attr
				controller.should be_signed_in
			end
			
		end
		
	end


	describe "GET 'edit'" do

		before(:each) do
			@user = FactoryGirl.create(:user)
			test_sign_in(@user)
		end

		it "returns http success" do
			get :edit , :id => @user 
			response.should be_success
		end

		it "should have the right title" do
			get :edit , :id => @user
			response.should have_selector('title' , :content => "Edit user" )
		end

		it "should have a link to change the Gravatar" do
			get :edit , :id => @user
			response.should have_selector('a' , :href => "http://gravatar.com/emails",
				:content => "change")
		end

	end


	describe "PUT 'update'" do
		before(:each) do
			@user = FactoryGirl.create(:user)
			test_sign_in(@user)
		end

		describe "failure" do
			before(:each) do
				@attr = {
					:name => "" ,
					:email => "" ,
					:password => "",
					:password_confirmation => ""
				}
			end 
			it "should re-render the edit page" do
				put :update , :id => @user,:user => @attr
				response.should render_template('edit')
			end
			it "should have the right title" do
				put :update , :id => @user,:user => @attr
				response.should have_selector('title',
					:content => "Edit user")
			end


		end

		describe "success" do
			before(:each) do
				@attr = {
					:name => "new name" ,
					:email => "new@email.com" ,
					:password => "foobar2",
					:password_confirmation => "foobar2"
				}
			end 

			it "should change the user's attributes" do
				put :update , :id => @user , :user =>@attr
				user = assigns(:user) 
				@user.reload 
				@user.name.should == user.name
				@user.email.should == user.email
				@user.encrypted_password.should == user.encrypted_password
			end

			it "should have the right title" do
				put :update , :id => @user , :user =>@attr
				response.should redirect_to(user_path(assigns(:user)))
			end

			it "should have a flash message" do
				put :update , :id => @user , :user =>@attr
				flash[:success] =~ /update succeded/i
			end
		end
	end

	describe "authentication of update/edit actions" do
		
		before(:each) do
			@user = FactoryGirl.create(:user)
		end
		describe "for non-signed-users" do
			it "should deny accsess to 'edit'" do
				get :edit , :id => @user 
				response.should redirect_to(signin_path)
				flash[:notice] =~ /sign in/i
			end

			it "should deny accsess to 'edit'" do
				put :update , :id => @user 
				response.should redirect_to(signin_path)
			end
		end

		describe "for signed-in user" do
			before(:each) do
				wrong_user = FactoryGirl.create(:user, :email => "other@email.com")
				test_sign_in(wrong_user)
			end

			it "should require matching users for 'edit'" do
				get :edit , :id => @user 
				response.should redirect_to(root_path)
			end


			it "should require matching users for 'update'" do
				put :update , :id => @user  , :user => {}
				response.should redirect_to(root_path)
			end
		end
		

	end

	describe "DELETE 'destroy'" do
		before(:each) do
			@user = FactoryGirl.create(:user)
		end

		describe "for not signed-in user" do
			it "should deny accsess" do
				delete :destroy , :id => @user 
				response.should redirect_to(signin_path)
			end
		end

		describe "as not admin user" do
			it "protect the action" do
				test_sign_in (@user)
				delete :destroy , :id => @user
				response.should redirect_to root_path
			end
		end
		describe "as an admin user" do

		before(:each) do
			@admin = FactoryGirl.create(:user ,:email => "admin@example.com" , :admin => true)
			test_sign_in(@admin)
		end

			it "should destroy user" do
				lambda do
					delete :destroy , :id => @user		
				end.should change(User,:count).by(-1)
			end

			it "should redirect to user page" do
				delete :destroy , :id => @user
				flash[:success].should =~ /destroyed/i
				response.should redirect_to users_path
			end

			it "should prevent admin from destroy himself" do
				lambda do
					delete :destroy , :id => @admin
				end.should_not change(User,:count)
			end
		end
	end


end
