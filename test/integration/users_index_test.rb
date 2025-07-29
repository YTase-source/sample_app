require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
  end

  test 'index as admin including pagination and delete links' do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    # will_paginateのリンクが2つとも存在しているかテスト
    assert_select 'div.pagination', count: 2
    first_page_of_users = User.paginate(page: 1)
    # ユーザ名のリンクと、管理者でない場合はdeleteリンクの表示をテスト
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      assert_select 'a[href=?]', user_path(user), text: 'delete' unless user == @admin
    end
    # deleteリクエストのテスト
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
      assert_response :see_other
      assert_redirected_to users_url
    end
  end

  # 非管理者ユーザでログインした場合の画面表示テスト
  test 'index as non-admin' do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end
