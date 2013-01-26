class UsersController < ApplicationController
  
  before_filter :authecticate, :only => [:edit,:update]

  def new
  	@title = "Sign up"
  	@user = User.new
  end

  def show
  	@user = User.find(params[:id])
  	@title = @user.name
  end

  def create 
  	@user = User.new params[:user]
  	if @user.save
      sign_in(@user)
      redirect_to user_path(@user) , :flash => {:success => " #{@user.name} , welcome to our app !"}
    else
      @title = "Sign up"
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
    @title = "Edit user"
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to user_path(@user) , :flash => {:success => "Update succeded"}
    else
      @title = "Edit user"
      render 'edit'
    end
  end


  private
    def authecticate
      deny_access unless signed_in?
    end

    def deny_access
      redirect_to signin_path , :notice = "Please sign in to access this page"
    end
end
