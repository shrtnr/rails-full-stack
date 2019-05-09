# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def test_index_without_admin_creds
    get users_url, user_authed
    assert_response(:unauthorized)

    assert_equal('user is unauthorized', json['error_message'])
  end

  def test_index
    user = users(:user)

    get users_url, admin_authed
    assert_response(:ok)
    assert_equal(2, json['total'])
    assert_equal(1, json['page'])
    assert_equal(20, json['per_page'])
    assert_equal(2, json['users'].length)

    assert_includes(json['users'].map { |u| u['email'] }, user.email)
    assert_includes(json['users'].map { |u| u['id'] }, user.id)
  end

  def test_index_pagination
    params = proc do
      {
        email: "test+#{unique_suffix}@example.com",
        password: 'password',
        password_confirmation: 'password'
      }
    end
    5.times { User.create(params.call) }

    get users_url(page: 2, per_page: 4), admin_authed
    assert_response(:ok)
    assert_equal(7, json['total'])
    assert_equal(2, json['page'])
    assert_equal(4, json['per_page'])
    assert_equal(3, json['users'].length)
  end

  def test_show
    user = users(:user)

    get user_url(user.id), unauthed
    assert_response(:ok)
    assert_equal(user.email, json.dig('user', 'email'))
    assert_equal(user.id, json.dig('user', 'id'))
  end

  def test_show_unknown_user
    get user_url('unknown'), unauthed
    assert_response(:not_found)
    assert_equal('user not found', json['error_message'])
  end

  def test_create
    params = {
      user: {
        email: "test+#{unique_suffix}@example.com",
        password: 'password',
        password_confirmation: 'password'
      }
    }

    post users_url, admin_authed(params: params)
    assert_response(:created)
    assert_match(%r{^#{users_url}/.*}, @response.headers['location'])
  end

  def test_create_with_bad_data
    params = { user: { password: 'new_password' } }
    post users_url, admin_authed(params: params)
    assert_response(:bad_request)
    assert_equal("can't be blank", json.dig('error_messages', 'email'))
    assert_equal("can't be blank", json.dig('error_messages', 'password_confirmation'))
  end

  def test_update
    user = users(:user)
    params = {
      user: {
        email: "test+#{unique_suffix}",
        password: 'password',
        password_confirmation: 'password'
      }
    }

    put user_url(user.id), admin_authed(params: params)
    assert_response(:ok)
    assert_equal(user_url(user.id), @response.headers['location'])
  end

  def test_update_with_bad_data
    user = users(:user)
    params = { user: { password: 'new_password' } }

    put user_url(user.id), admin_authed(params: params)
    assert_response(:bad_request)
    assert_equal("can't be blank", json.dig('error_messages', 'password_confirmation'))
  end

  def test_update_with_unknown_user
    params = { user: { password: 'new_password' } }

    put user_url('unknown'), admin_authed(params: params)
    assert_response(:not_found)
    assert_equal('user not found', json['error_message'])
  end

  def test_delete
    user = users(:user)

    delete user_url(user.id), admin_authed
    assert_response(:ok)
  end

  def test_delete_with_unknown_user
    delete user_url('unknown'), admin_authed
    assert_response(:not_found)
    assert_equal('user not found', json['error_message'])
  end

  def test_auth
    params = { email: 'user@example.com', password: 'password' }

    post auth_users_url, unauthed(params: params)
    assert_response(:ok)

    payload = JWT.decode(json['token'], nil, false) # skip validation
    assert_equal('user@example.com', payload.first['sub'])
  end

  def test_authenticate_with_unknown_user
    params = { email: 'nobody@example.com', password: 'not_the_password' }

    post auth_users_url, unauthed(params: params)
    assert_response(:unauthorized)
    assert_equal('user is unauthorized', json['error_message'])
  end

  def test_authenticate_with_bad_credentials
    params = { email: 'user@example.com', password: 'not_the_password' }

    post auth_users_url, unauthed(params: params)
    assert_response(:unauthorized)
    assert_equal('user is unauthorized', json['error_message'])
  end
end
