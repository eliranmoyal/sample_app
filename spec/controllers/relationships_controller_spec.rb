require 'spec_helper'

describe RelationshipsController do
	describe "deny accssess from unsigned users" do

		it "should deny accssess to create" do
			post :create
			response.should redirect_to(signin_path)
		end

		it "should deny accssess to create" do
			delete :destroy, :id => 1
			response.should redirect_to(signin_path)
		end

	end


	describe "POST 'create'" do
		before(:each) do
			@user = test_sign_in(FactoryGirl.create(:user))
			@followed = FactoryGirl.create(:user , :email => FactoryGirl.generate(:email))
		end

		it "should create a relationship" do
			lambda do
				post :create , :relationship => {:followed_id => @followed}
				response.should redirect_to(user_path(@followed))
			end.should change(Relationship,:count).by(1)
		end
		
		it "should create a relationship with ajax" do
			lambda do
				xhr :post , :create , :relationship => {:followed_id => @followed}
				response.should be_success
			end.should change(Relationship,:count).by(1)
		end

	end


	describe "DELETE 'destroy'" do
			before(:each) do
			@user = test_sign_in(FactoryGirl.create(:user))
			@followed = FactoryGirl.create(:user , :email => FactoryGirl.generate(:email))
			@user.follow!(@followed)
			@relationship = @user.relationships.find_by_followed_id(@followed)
		end

		it "should delete a relationship" do
			lambda do
				delete :destroy , :id => @relationship.id
				response.should redirect_to(user_path(@followed))
			end.should change(Relationship,:count).by(-1)
		end

		it "should delete a relationship in ajax" do
			lambda do
				xhr :delete, :destroy , :id => @relationship.id
				response.should be_success
			end.should change(Relationship,:count).by(-1)
		end
	end


end
