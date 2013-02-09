class UsersController < ApplicationController

  before_filter :authecticate, :except => [:show, :new , :create]
  before_filter :correct_user, :only => [:edit,:update]
  before_filter :admin_user , :only => [:destroy]

  def index
    @users = User.paginate(:page => params[:page])
    @title = "All users"
  end

  def new
  	@title = "Sign up"
  	@user = User.new
  end

  def show
  	@user = User.find(params[:id])
    @microposts = @user.microposts.paginate(:page => params[:page])
  	@title = @user.name
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(:page => params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(:page => params[:page])
    render 'show_follow'
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
    @title = "Edit user"
  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to user_path(@user) , :flash => {:success => "Update succeded"}
    else
      @title = "Edit user"
      render 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path , :flash => {:success => "User destroyed"}
  end


  private
  def authecticate
    deny_access unless signed_in?
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to root_path unless current_user?(@user)
  end

  def admin_user
    @user = User.find(params[:id])
    redirect_to(root_path) if (!current_user.admin? || current_user?(@user) )
  end
end
