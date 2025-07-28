require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'successful edit with friendly forwarding' do
    get edit_user_path(@user) # ログイン前のため、フレンドリーフォワーディングを行う
    assert_equal edit_user_url(@user), session[:forwarding_url] # session[:forwarding_url]に格納されているかテスト

    # 1回目のログイン（直前にリクエストしたURLにリダイレクト）
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    name  = 'Foo Bar'
    email = 'foo@bar.com'
    patch user_path(@user), params: { user: { name: name,
                                              email: email,
                                              password: '',
                                              password_confirmation: '' } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email

    # 2回目のログイン（デフォルトのプロフィール画面にリダイレクト）
    log_in_as(@user)
    assert_redirected_to user_url(@user)
  end

  test 'unsuccessful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name: '',
                                              email: 'foo@invalid',
                                              password: 'foo',
                                              password_confirmation: 'bar' } }

    assert_template 'users/edit'
    assert_select 'div.alert'
  end
end
