# == Schema Information
#
# Table name: microposts
#
#  id         :integer          not null, primary key
#  content    :string(255)
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Micropost do

  before(:each) do
  	@user = FactoryGirl.create(:user)
  	@attr = {:content => "hello all" }
  end

  it "should create a valid micropost" do
  	@user.microposts.create!(@attr)
  end

  describe "user attribute" do
  	before(:each) do
  		@micropost = @user.microposts.create(@attr)
  	end


  	it "should have a user attribute" do
  		@micropost.should respond_to(:user)
  	end

  	it "should have the right associeted user" do
  		@micropost.user_id.should == @user.id
  		@micropost.user == @user
  	end

  end

  describe "validations" do

  	it "should have a user id" do
  		Micropost.new(@attr).should_not be_valid
  	end

  	it "should require a non blank content" do
  		@user.microposts.build(:content => "  ").should_not be_valid
  	end

  	it "should reject long content" do
  		@user.microposts.build(:content => "a"*141).should_not be_valid
  	end
  end

  describe "from user followed by" do

    before(:each) do
      @followed = FactoryGirl.create(:user , :email=>FactoryGirl.generate(:email))
      @other_user = FactoryGirl.create(:user , :email=>FactoryGirl.generate(:email))
      @user_micropost = @user.microposts.create!(:content => "hey")
      @followed_micropost = @followed.microposts.create!(:content => "bye")
      @other_user_micropost = @other_user.microposts.create!(:content => "why")
      @user.follow!(@followed)
    end

    it "should show the user microposts" do
        Micropost.from_user_followed_by(@user).should include(@user_micropost)
    end

    it "should show the users followed micropost" do
      Micropost.from_user_followed_by(@user).should include(@followed_micropost)
    end

    it "should not show the other user micropost" do
      Micropost.from_user_followed_by(@user).should_not include(@other_user_micropost)
    end
  end

end
