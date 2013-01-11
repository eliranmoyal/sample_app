# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe User do

	before(:each) do
		@attr = {:name => "Example User" , :email => "user@example.com" }
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
end
