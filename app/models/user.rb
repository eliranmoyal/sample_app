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

class User < ActiveRecord::Base
  attr_accessible :email, :name, :password , :password_confirmation
  attr_accessor :password,:salt

  email_regex = /\A[\w+.\-]+@[a-z\d\-]+(\.[a-z]+)+\z/i
  validates :name , :presence => true ,
  					:length => {:maximum => 40}
  validates :email , :presence => true,
  					 :format => {:with => email_regex},
  					 :uniqueness => {:case_sensitive=>false}
  validates :password, :presence => true,
  					   :confirmation => true,
  					   :length => { :within => 6..40 }

  before_save :encrypt_password

  def User.authenticate(email,submitted_password)
    user == find_be_email(email)
    return nil if user.nil?
    return user if user.has_password?(submitted_password)
  end

  def has_password?(submitted_password)
    self.encrypted_password == encrypt(submitted_password) 
  end

  private 

  	def encrypt_password
      self.salt = make_salt if new_record?
  		self.encrypted_password = encrypt(password)
  	end

  	def encrypt(string)
  		secure_hash("#{salt}--#{string}")
  	end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end
  
end
