FactoryGirl.define do 
	factory :user do |user|
		user.name					"foo bar"
		user.email					"foo@bar.com"
		user.password 			   "foobar"
		user.password_confirmation "foobar"
	end
end