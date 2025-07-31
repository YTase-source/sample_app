require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test 'invalid signup information' do
    get signup_path
    # 無効な値でuser追加しようとした時に、User.countが変化しないことを確認する
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: '',
                                         email: 'user@invalid',
                                         password: 'foo',
                                         password_confirmation: 'bar' } }
    end
    # HTTPステータスコード 422 (Unprocessable Entity) が帰ってくることを確認する
    assert_response :unprocessable_entity
    assert_template 'users/new'
    assert_select '#user_name'
    assert_select '#user_email'
    assert_select '#user_password'
    assert_select '#user_password_confirmation'
    assert_select '.field_with_errors'
  end

  test 'valid signup information' do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: 'Example User',
                                         email: 'user@realdomain.com',
                                         password: 'password',
                                         password_confirmation: 'password' } }
    end
    follow_redirect!
    # assert_template 'users/show'
    # assert_not flash.empty?
    # assert is_logged_in?
  end
end
