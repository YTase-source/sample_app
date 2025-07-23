require 'test_helper'

class UsersLogin < ActionDispatch::IntegrationTest
  # fixtureの取得
  def setup
    @user = users(:michael)
  end

  # 複数ウィンドウでログインしている状態からそれぞれログアウトした場合のテスト
  test 'login with valid information followed by logout' do
    post login_path, params: { session: { email: @user.email,
                                          password: 'password' } }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select 'a[href=?]', login_path, count: 0
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', user_path(@user)
    # 1番目のウィンドウでログアウトをクリックするユーザーをシミュレートする
    delete logout_path
    assert_response :see_other
    assert_not is_logged_in?
    assert_redirected_to root_url
    # 2番目のウィンドウでログアウトをクリックするユーザーをシミュレートする
    delete logout_path
    follow_redirect!
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', logout_path,      count: 0
    assert_select 'a[href=?]', user_path(@user), count: 0
  end
end

# -------------------------------------------------------
# 無効なログイン認証をPOSTした際のテスト
# -------------------------------------------------------
class InvalidPasswordTest < UsersLogin
  # ログイン画面が開けるかのテスト
  test 'login pass' do
    get login_path
    assert_template 'sessions/new'
  end

  # emailは有効だが、passwordが無効な情報をPOSTした際のテスト
  test 'login with valid email/invalid password' do
    post login_path, params: { session: { email: @user.email,
                                          password: 'invalid' } }
    assert_not is_logged_in?
    assert_response :unprocessable_entity
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
end

# -------------------------------------------------------
# 有効なログイン認証をPOSTした際のテスト
# -------------------------------------------------------
class ValidLogin < UsersLogin
  def setup
    super
    # paramsハッシュを使ってセッション用パスにPOSTする
    post login_path, params: { session: { email: @user.email, password: 'password' } }
  end
end

class ValidLoginTest < ValidLogin
  # セッションにログイン情報があるかのテスト
  test 'valid login' do
    assert is_logged_in?
    # リダイレクト先が正しいかチェック
    assert_redirected_to @user
  end

  # ログイン後、ユーザー画面にリダイレクトできるかのテスト
  test 'redirect after login' do
    # リダイレクトを実行
    follow_redirect!
    # 移動先のページが正しいか確認
    assert_template 'users/show'
    # ログイン前のリンクがなくなり、ログイン後のリンクが表示されているか確認
    assert_select 'a[href=?]', login_path, count: 0
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', user_path(@user)
  end
end

# -------------------------------------------------------
# ログアウトした際のテスト
# -------------------------------------------------------
class Logout < ValidLogin
  def setup
    super
    # destroyアクションへリクエストを送る
    delete logout_path
  end
end

class LogoutTest < Logout
  # ログアウトが実行できるかのテスト
  test 'successful logout' do
    # ログアウトしているか確認
    assert_not is_logged_in?
    # リダイレクトできるか確認
    assert_response :see_other
    assert_redirected_to root_url
  end

  # ログアウト後、Home画面にリダイレクトできるかのテスト
  test 'redirect after logout' do
    # リダイレクトを実行
    follow_redirect!
    # ログイン後のリンクがなくなり、ログイン前のリンクが表示されているか確認
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', logout_path,      count: 0
    assert_select 'a[href=?]', user_path(@user), count: 0
  end

  # test 'login with valid information followed by logout' の別バージョン
  test 'should still work after logout in second window' do
    delete logout_path
    assert_redirected_to root_url
  end
end

class RememberingTest < UsersLogin
  # remember_meチェックボックスが有効の場合のテスト
  test 'login with remembering' do
    log_in_as(@user, remember_me: '1')
    assert_equal cookies[:remember_token], assigns(:user).remember_token
    assert_not cookies[:remember_token].blank?
  end

  # remember_meチェックボックスが無効の場合のテスト
  test 'login without remembering' do
    # Cookieを保存してログイン
    log_in_as(@user, remember_me: '1')
    # Cookieが削除されていることを検証してからログイン
    log_in_as(@user, remember_me: '0')
    assert cookies[:remember_token].blank?
  end
end
