require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def test_index_without_admin_creds
    get users_url, user_authed
    assert_response(:unauthorized)

    assert_equal("error", json["status"])
    assert_equal("unauthorized", json.dig("errors", "admin"))
  end

  def test_index
    user = users(:user)

    get users_url, admin_authed
    assert_response(:ok)
    assert_equal("ok", json["status"])
    assert_includes(json["users"].map { |u| u["email"] }, user.email)
    assert_includes(json["users"].map { |u| u["id"] }, user.id)
  end

  def test_show
    user = users(:user)

    get user_url(user.id), unauthed
    assert_response(:ok)
    assert_equal("ok", json["status"])
    assert_equal(user.email, json.dig("user", "email"))
    assert_equal(user.id, json.dig("user", "id"))
  end

  def test_show_unknown_user
    get user_url("unknown"), unauthed
    assert_response(:not_found)
    assert_equal("error", json["status"])
    assert_equal("not found", json.dig("errors", "user"))
  end

  def test_create
    params = {
      user: {
        email: "test+#{unique_suffix}",
        password: "password",
        password_confirmation: "password"
      }
    }

    post users_url, admin_authed(params: params)
    assert_response(:created)
    assert_equal("ok", json["status"])
    assert_match(%r(^#{users_url}/.*), json["location"])
    assert_match(%r(^#{users_url}/.*), @response.headers["location"])
  end

  def test_create_with_bad_data
    params = { user: { password: "new_password" } }
    post users_url, admin_authed(params: params)
    assert_response(:bad_request)
    assert_equal("error", json["status"])
    assert_equal("can't be blank", json.dig("errors", "email"))
    assert_equal("can't be blank", json.dig("errors", "password_confirmation"))
  end

  def test_update
    user = users(:user)
    params = {
      user: {
        email: "test+#{unique_suffix}",
        password: "password",
        password_confirmation: "password"
      }
    }

    put user_url(user.id), admin_authed(params: params)
    assert_response(:ok)
    assert_equal("ok", json["status"])
    assert_equal(user_url(user.id), json["location"])
    assert_equal(user_url(user.id), @response.headers["location"])
  end

  def test_update_with_bad_data
    user = users(:user)
    params = { user: { password: "new_password" } }

    put user_url(user.id), admin_authed(params: params)
    assert_response(:bad_request)
    assert_equal("error", json["status"])
    assert_equal("can't be blank", json.dig("errors", "password_confirmation"))
  end

  def test_update_with_unknown_user
    params = { user: { password: "new_password" } }

    put user_url("unknown"), admin_authed(params: params)
    assert_response(:not_found)
    assert_equal("error", json["status"])
    assert_equal("not found", json.dig("errors", "user"))
  end

  def test_delete
    user = users(:user)

    delete user_url(user.id), admin_authed
    assert_response(:ok)
    assert_equal("ok", json["status"])
  end

  def test_delete_with_unknown_user
    delete user_url("unknown"), admin_authed
    assert_response(:not_found)
    assert_equal("error", json["status"])
    assert_equal("not found", json.dig("errors", "user"))
  end

  def test_auth
    params = { email: "user@example.com", password: "password" }

    post auth_users_url, unauthed(params: params)
    assert_response(:ok)
    assert_equal("ok", json["status"])

    payload = JWT.decode(json["token"], nil, false) # skip validation
    assert_equal("user@example.com", payload.first["sub"])
  end

  def test_authenticate_with_unknown_user
    params = { email: "nobody@example.com", password: "not_the_password" }

    post auth_users_url, unauthed(params: params)
    assert_response(:unauthorized)
    assert_equal("error", json["status"])
    assert_equal("unauthorized", json.dig("errors", "user"))
  end

  def test_authenticate_with_bad_credentials
    params = { email: "user@example.com", password: "not_the_password" }

    post auth_users_url, unauthed(params: params)
    assert_response(:unauthorized)
    assert_equal("error", json["status"])
    assert_equal("unauthorized", json.dig("errors", "user"))
  end
end
