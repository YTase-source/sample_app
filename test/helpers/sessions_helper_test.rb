require 'test_helper'

class SessionsHelperTest < ActionView::TestCase
  # セッションを設定しないで、永続的セッションのみを設定する
  def setup
    # fixtureを使用してmichaelインスタンスを作成
    @user = users(:michael)
    remember(@user)
  end

  # セッションがnilの時に正しくcurrent_userが更新できているか
  test 'current_user returns right user when session is nil' do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  # ユーザーの記憶ダイジェストが記憶トークンと正しく対応していない場合にnilになるか
  test 'current_user returns nil when remember digest is wrong' do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end
