require 'spec_helper'

describe "Users" do
	describe "signup integration" do
		describe "failure" do
			it "should not make a new user" do
				lambda do
					visit signup_path
					fill_in 'Name' , 		:with => ""
					fill_in 'Email' , 		:with => ""
					fill_in 'Password',		:with => ""
					fill_in 'Confirmation',	:with => ""
					click_button 'Sign up'
					response.should render_template('users/new')
					response.should have_selector('div#errors_description')
				end.should_not change(User,:count)
			end
		end
		describe "success" do
			it "should not make a new user" do
				lambda do
					visit signup_path
					fill_in 'Name' , 		:with => "eliran"
					fill_in 'Email' , 		:with => "eliran@gmail.com"
					fill_in 'Password',		:with => "foobar"
					fill_in 'Confirmation',	:with => "foobar"
					click_button 'Sign up'
					response.should have_selector('div.flash.success',:content => "welcome")
					response.should render_template('users/show')
				end.should change(User,:count).by(1)
			end
		end
	end
end
