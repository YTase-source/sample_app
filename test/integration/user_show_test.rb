require 'test_helper'

class UsersShowTest < ActionDispatch::IntegrationTest
  def setup
    @inactive_user  = users(:inactive)
    @activated_user = users(:archer)
  end

  test 'should redirect when user not activated' do
    get user_path(@inactive_user)
    assert_response :redirect
    assert_redirected_to root_url
  end

  test 'should display user when activated' do
    get user_path(@activated_user)
    assert_response :success
    assert_template 'users/show'
  end

  test 'should display stats on profile page' do
    get user_path(@activated_user)
    assert_template 'users/show'
    # statsパーシャルの情報を確認
    assert_select '.stats' do
      assert_select 'a[href=?]', following_user_path(@activated_user)
      assert_select 'a[href=?]', followers_user_path(@activated_user)
      assert_match @activated_user.following.count.to_s, response.body
      assert_match @activated_user.followers.count.to_s, response.body
      assert_select 'strong.stat', count: 2
    end
  end
end
