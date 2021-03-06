# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean          default(FALSE)
#

require 'spec_helper'

describe User do

	before(:each) do
		@attr = {
			:name => "Example User" ,
			:email => "user@example.com" ,
			:password => "Password",
			:password_confirmation => "Password"
		}
	end

	it "should create a new instance given a valid attribute" do
		User.create!(@attr)
	end

	it "should require a name" do
		user_without_name = User.new(@attr.merge(:name=> ""))
		user_without_name.should_not be_valid
	end 

	it "should require an email address"  do
		user_without_email = User.new(@attr.merge(:email => ""))
		user_without_email.should_not be_valid
	end

	it "should not have a very long name" do
		long_name = "a" * 41
		user_with_long_name = User.new(@attr.merge(:name => long_name))
		user_with_long_name.should_not be_valid
	end

	it "should accept valid email addresses" do
		addresses = %w[foo@bar.com FOO_BAR@bar.co.il first.last@gmail.com]
		addresses.each do |address|
			user_with_valid_email = User.new(@attr.merge(:email => address))
			user_with_valid_email.should be_valid
		end
	end

	it "should reject invalid addresses" do
		addresses = %w[foo@bar,com FOO_BARbar.co.il first.last@gmail.]
		addresses.each do |address|
			user_with_invalid_email = User.new(@attr.merge(:email => address))
			user_with_invalid_email.should_not be_valid
		end
	end

	it "should reject duplicate email address" do
		duplicate_email = "foo@bar.com"
		first_user = User.create!(@attr.merge(:email=>duplicate_email))
		first_user.should be_valid
		second_user = User.new(@attr.merge(:email=>duplicate_email))
		second_user.should_not be_valid
	end

	it "should reject email identical up to case" do
		email = "user@bar.com"
		up_case_email = email.upcase
		User.create!(@attr.merge(:email=>email))
		up_case_user = User.new(@attr.merge(:email=>up_case_email))
		up_case_user.should_not be_valid
	end
	
	describe "passwords" do

		before(:each) do
			@user = User.new(@attr)
		end

		it "should have passsword property" do
			@user.should respond_to(:password)
		end
		
		it "should have a password confermation attribute" do
			@user.should respond_to(:password_confirmation)
		end
		
	end

	describe "password validations" do
		
		it "should require a password" do
			user_without_password = User.new(@attr.merge(:password => "", :password_confirmation => ""))
			user_without_password.should_not be_valid
		end

		it "should require a matching confermation" do
			User.new(@attr.merge( :password_confirmation => "invalid")).
			should_not be_valid
		end

		it "should reject short passwords" do
			short = "a"*5
			User.new(@attr.merge(:password => short,:password_confirmation => short)).
			should_not be_valid
		end


		it "should reject long passwords" do
			long = "a"*41
			User.new(@attr.merge(:password => long,:password_confirmation => long)).
			should_not be_valid
		end

	end

	describe "encripted passwords" do

		before(:each) do
			@user = User.create!(@attr)
		end

		it "should have an encrypted password attribute" do
			@user.should respond_to(:encrypted_password)
		end

		it "should not have a blank encrypted password" do
			@user.encrypted_password.should_not be_blank
			
		end
		
		describe "has_password? mathod" do
			it "should exist" do
				@user.should respond_to(:has_password?)
			end

			it "should return true if the password match" do
				@user.has_password?(@attr[:password]).should be_true	
			end

			it "should return false if the password did not match" do
				@user.has_password?("invalid").should be_false
			end

		end

		describe "authenticate method" do

			it "should exist" do
				User.should respond_to(:authenticate)
			end

			it "should return nil if email/password mismatch" do
				User.authenticate(@attr[:email],"wrongpass").should be_nil
			end

			it "should return nil if there is no such user" do
				User.authenticate("no@email.com",@attr[:password]).should be_nil
			end

			it "should return the user if email/password match" do
				User.authenticate(@attr[:email],@attr[:password]).should == @user
			end


		end
		
	end

	describe "addmin attribute" do
		before(:each) do
			@user = FactoryGirl.create(:user)
		end

		it "should respond to admin" do
			@user.should respond_to(:admin)
		end

		it "should not be admin by default" do
			@user.should_not be_admin
		end
		it "should be convertable to admin" do
			@user.toggle!(:admin)
			@user.should be_admin
		end
	end

	describe "microposts attribute" do
		before(:each) do
			@user = FactoryGirl.create(:user)
			@mp1 = FactoryGirl.create(:micropost,:user => @user , :created_at => 1.day.ago)
			@mp2 = FactoryGirl.create(:micropost,:user => @user , :created_at => 1.hour.ago)
		end

		it "should respond to microposts" do
			@user.should respond_to(:microposts)
		end

		it "should have the right micropost in the right order" do
			@user.microposts.should == [@mp2,@mp1]
		end

		it "should destroy associated microposts" do
			@user.destroy
			[@mp1,@mp2].each do |m|
				lambda do 
					Micropost.find(m.id)
				end.should raise_error(ActiveRecord::RecordNotFound)
			end 
		end

		describe "status feed" do
			it "should have a feed" do
				@user.should respond_to(:feed)
			end

			it "should include user's microposts" do
				@user.feed.should include(@mp1)
				@user.feed.should include(@mp2)
			end

			it "should not include a different user's microposts" do
				mp3 = FactoryGirl.create(:micropost , :user => 
					FactoryGirl.create(:user,:email => FactoryGirl.generate(:email)))
				@user.feed.should_not include(mp3)
			end

			it "should include a followed user's microposts" do
				followed = FactoryGirl.create(:user,:email => FactoryGirl.generate(:email))
				mp3 = FactoryGirl.create(:micropost,:user => followed)
				@user.follow!(followed)
				@user.feed.should include(mp3)
			end
		end
	end

	describe "relationships" do
		before(:each) do
			@user = FactoryGirl.create(:user)
			@followed = FactoryGirl.create(:user,:email=>FactoryGirl.generate(:email)) 
		end

		it "should have relationships" do
			@user.should respond_to(:relationships)
		end


		it "should have a following method" do
			@user.should respond_to(:following)
		end

		it "should follow another user" do
			@user.follow!(@followed)
			@user.should be_following(@followed)
		end

		it "should include the followed user in the following array" do
			@user.follow!(@followed)
			@user.following.should include(@followed)
		end
		

		it "should have a unfollow method" do
			@user.should respond_to(:unfollow!)
		end

		it "should follow another user" do
			@user.follow!(@followed)
			@user.unfollow!(@followed)
			@user.should_not be_following(@followed)
		end

		it "should have a reverse relationships method" do
			@user.should respond_to(:reverse_relationships)
		end

		it "should have a followers method" do
			@user.should respond_to(:followers)
		end

		it "should include the user in the followers array" do
			@user.follow!(@followed)
			@followed.followers.should include(@user)
		end

	end




end
