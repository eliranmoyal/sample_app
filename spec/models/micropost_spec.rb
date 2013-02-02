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

end
