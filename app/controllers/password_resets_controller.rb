class PasswordResetsController < ApplicationController
  before_filter :require_no_user
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]

  def new
    render
  end

  def create
    if params[:comment].empty?
      @user = User.find_by_email(params[:email])
      if @user
        @user.deliver_password_reset_instructions!
        redirect_to root_url, :notice => "Instructions to reset your password have been emailed to you. " +
        "Please check your email."
      else
        render :action => :new, :alert => "No user was found with that email address."
      end
    else
      redirect_to root_url, :alert => "You appear bot-like."
    end
  end
  
  def edit
    render
  end  
  
  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      redirect_to root_url, :notice =>  "Password successfully updated"
    else
      render :action => :edit
    end
  end
  
  private
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:error] = "We're sorry, but we could not locate your account. " +
      "If you are having issues, try copying and pasting the URL " +
      "from your email into your browser or restarting the " +
      "reset password process."
      redirect_to root_url
    end
  end
  
end
