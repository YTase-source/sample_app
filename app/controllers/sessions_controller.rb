class SessionsController < ApplicationController
  def new; end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user&.authenticate(params[:session][:password])
      forwarding_url = session[:forwarding_url]
      reset_session # ログインの直前に必ずこれを書くこと
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
      log_in @user
      redirect_to forwarding_url || @user
      # debugger
    else
      # エラーメッセージを作成する
      flash.now[:danger] = 'Invalid email/password combination' # 本当は正しくない
      render 'new', status: :unprocessable_entity
    end
  end

  # # 現在のユーザーをログアウトする（ヘルパーメソッドに移動しました）
  # def log_out
  #   reset_session
  #   @current_user = nil # 安全のため
  # end

  def destroy
    log_out if logged_in?
    redirect_to root_url, status: :see_other # HTTP303ステータスにする
  end
end
