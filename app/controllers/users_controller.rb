class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    debugger
  end

  def new
    debbuger
  end
end
