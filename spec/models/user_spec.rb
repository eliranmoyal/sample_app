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
		end
		
	end



end
