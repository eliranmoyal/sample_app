# == Schema Information
#
# Table name: relationships
#
#  id          :integer          not null, primary key
#  follower_id :integer
#  followed_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

describe Relationship do

	before(:each) do
		@follower = FactoryGirl.create(:user)
		@followed = FactoryGirl.create(:user , :email => FactoryGirl.generate(:email))
		@attr = {:followed_id => @followed.id}
	end

	it "should create a valid relationship" do
		@follower.relationships.create!(@attr)
	end

	describe "follow methods" do
		before(:each) do
			@relation = @follower.relationships.create(@attr)
		end
		it "should have a follower method" do
			@relation.should respond_to(:follower)
		end
		it "should have the right follower" do
			@relation.follower.should == @follower
		end

		it "should have a folllowed method" do
			@relation.should respond_to(:followed)
		end
		it "should follow the right user" do
			@relation.followed.should == @followed
		end

	end

	describe "validations" do
		it "should require a follower_id" do
			Relationship.new(@attr).should_not be_valid
		end


		it "should require a followed_id" do
			@follower.relationships.build().should_not be_valid
		end
	end
end
