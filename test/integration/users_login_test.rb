require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  # fixtureの取得
  def setup
    @user = users(:michael)
  end

  # 無効なログイン情報をPOSTした際の挙動確認
  test 'login with invalid information' do
    # ログイン用のパスを開く
    get login_path
    # 新しいセッションのフォームが正しく表示されたことを確認する
    assert_template 'sessions/new'
    # わざと無効なparamsハッシュを使ってセッション用パスにPOSTする
    post login_path, params: { session: { email: '', password: '' } }
    # 新しいセッションのフォームが正しいステータスを返し、再度表示されることを確認する
    assert_response :unprocessable_entity
    assert_template 'sessions/new'
    # フラッシュメッセージが表示されることを確認する
    assert_not flash.empty?
    # 別のページ（Homeページなど） にいったん移動する
    get root_path
    # 移動先のページでフラッシュメッセージが表示されていないことを確認する
    assert flash.empty?
  end

  # 有効なログイン情報をPOSTした際の挙動確認
  test 'login with valid information' do
    # paramsハッシュを使ってセッション用パスにPOSTする
    post login_path, params: { session: { email: @user.email,
                                          password: 'password' } }
    # リダイレクト先が正しいかチェック
    assert_redirected_to @user
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
