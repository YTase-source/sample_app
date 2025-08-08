require 'test_helper'
require 'helpers/application_helper_test'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'layout links' do
    get root_path
    assert_template 'static_pages/home'
    assert_select 'a[href=?]', root_path, count: 2
    assert_select 'a[href=?]', help_path
    assert_select 'a[href=?]', about_path
    assert_select 'a[href=?]', contact_path
    get contact_path
    assert_select 'title', full_title('Contact')
    get signup_path
    assert_select 'title', full_title('Sign up')
  end

  def check_header_link
    assert_select 'a[href=?]', root_path, count: 2
    assert_select 'a[href=?]', help_path
    assert_select 'a[href=?]', users_path

    # ドロップダウンメニュー
    if is_logged_in?
      assert_select 'a[href=?]', user_path(@user)
      assert_select 'a[href=?]', edit_user_path(@user)
      assert_select 'a[href=?]', logout_path
    else
      assert_select 'a[href=?]', login_path
    end
  end

  def check_footer_link
    assert_select 'a[href=?]', about_path
    assert_select 'a[href=?]', contact_path
    assert_select 'a[href=?]', 'https://news.railstutorial.org/'
  end

  test 'users index layout links' do
    # 未ログインの場合
    get users_path
    assert_redirected_to login_url

    # ログイン済の場合
    log_in_as(@user)
    get users_path
    assert check_header_link
    assert check_footer_link
  end

  test 'home page display when logged in' do
    log_in_as(@user)
    get root_path
    assert_template 'static_pages/home'
    # statsパーシャルの情報を確認
    assert_select '.stats' do
      assert_select 'a[href=?]', following_user_path(@user)
      assert_select 'a[href=?]', followers_user_path(@user)
      assert_match @user.following.count.to_s, response.body
      assert_match @user.followers.count.to_s, response.body
      assert_select 'strong.stat', count: 2
    end
  end
end
