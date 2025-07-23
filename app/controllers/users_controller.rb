class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    # debugger
  end

  def new
    @user = User.new
    # debbuger
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # 保存の成功をここで扱う。
      # redirect_to @user
      reset_session
      log_in @user
      flash[:success] = 'Welcome to the Sample App!'
      redirect_to user_url(@user)
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end
end
