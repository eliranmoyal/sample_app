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

class Micropost < ActiveRecord::Base
	attr_accessible :content

	belongs_to :user

	validates :content , :presence => true ,
	:length => {:maximum => 140}
	validates :user_id , :presence => true 

	default_scope :order => 'microposts.created_at DESC' 

	def self.from_user_followed_by(user)
		following_ids = "SELECT followed_id FROM relationships where follower_id =:user_id"
		Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id" , :user_id => user.id)
	end
end
