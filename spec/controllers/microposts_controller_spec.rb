require 'spec_helper'

describe MicropostsController do
	render_views


	describe "accssess control" do
		it "should deny access to create" do
			post :create 
			response.should redirect_to signin_path
		end
		it "should deny accssess to destroy" do
			delete :destroy , :id => 1
			response.should redirect_to signin_path
		end
	end
	describe "POST 'create'" do
		before(:each) do
			@user = FactoryGirl.create(:user)
			test_sign_in(@user)
		end

		describe "failure" do

			before(:each) do
				@attr = {:content => "" }
			end

			it "should not create micropost" do
				lambda do
					post :create , :micropost => @attr
				end.should_not change(Micropost,:count)
			end

			it "should render home path" do
				post :create , :micropost => @attr
				response.should render_template('pages/home')
			end
		end

		describe "succssess" do

			before(:each) do
				@attr = {:content => "Hey m8" }
			end
			
			it "should create a micropost" do
				lambda do
					post :create , :micropost => @attr
				end.should change(Micropost,:count).by(1)
			end

			it "should redirect to root path" do
				post :create , :micropost => @attr
				response.should redirect_to root_path
			end

			it "should show good flash " do
				post :create , :micropost => @attr
				flash[:success] =~ /micropost created/i	
			end
		end
	end

	describe "DELETE 'destroy'" do
		describe "for unauthorized user" do
			before(:each) do
				@user = FactoryGirl.create(:user)
				bad_user = FactoryGirl.create(:user,:email => FactoryGirl.generate(:email))
				@mp1 = FactoryGirl.create(:micropost , :user => @user)	
				test_sign_in(bad_user)
			end
			it "should deny accssess" do
				delete :destroy , :id => @mp1
				response.should redirect_to root_path
			end
		end

		describe "for an authorized user" do
			before(:each) do
				@user = FactoryGirl.create(:user)
				@mp = FactoryGirl.create(:micropost , :user => @user)	
				test_sign_in(@user)
			end

			it "should destroy the micropost" do
				lambda do
					delete :destroy , :id => @mp
					response.should redirect_to root_path
					flash[:success].should =~ /micropost deleted/i
				end.should change(Micropost,:count).by(-1)
			end

			it "should redirect" do
				
			end
		end
	end
end
