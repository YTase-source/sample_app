class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      # turbo_stream アクションを呼び出す→create.turbo_stream.erbを探索する
      format.turbo_stream
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user, status: :see_other }
      # turbo_stream アクションを呼び出す→destroy.turbo_stream.erbを探索する
      format.turbo_stream
    end
  end
end
