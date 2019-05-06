require 'test_helper'

class ShortcodesControllerTest < ActionDispatch::IntegrationTest
  def test_index_without_creds
    get shortcodes_url, unauthed
    assert_response(:unauthorized)
    assert_equal("error", json["status"])
    assert_equal("unauthorized", json.dig("errors", "user"))
  end

  def test_index
    get shortcodes_url, user_authed
    assert_response(:ok)
    assert_equal("ok", json["status"])

    assert_includes(json["shortcodes"].map { |s| s["key"] }, shortcodes(:this).key)
    assert_includes(json["shortcodes"].map { |s| s["url"] }, shortcodes(:this).url)
    refute_includes(json["shortcodes"].map { |s| s["key"] }, shortcodes(:other).key)
  end

  def test_show
    shortcode = shortcodes(:this)

    get shortcode_url(shortcode.id), user_authed
    assert_response(:ok)
    assert_equal(shortcode.key, json.dig("shortcode", "key"))
    assert_equal(shortcode.url, json.dig("shortcode", "url"))
  end

  def test_show_for_other_account
    shortcode = shortcodes(:other)

    get shortcode_url(shortcode.id), user_authed
    assert_response(:not_found)
    assert_equal("error", json["status"])
    assert_equal("not found", json.dig("errors", "shortcode"))
  end

  def test_create
    params = {
      shortcode: {
        key: "#{unique_suffix}",
        url: "https://#{unique_suffix}.example.com"
      }
    }

    post shortcodes_url, user_authed(params: params)
    assert_response(:created)
    assert_equal("ok", json["status"])
    assert_match(%r(^#{shortcodes_url}/.*), json["location"])
    assert_match(%r(^#{shortcodes_url}/.*), @response.headers["location"])
  end

  def test_create_with_bad_data
    params = { shortcode: { x: "x" } } # required param can't be empty
    post shortcodes_url, user_authed(params: params)
    assert_response(:bad_request)
    assert_equal("error", json["status"])
    assert_equal("can't be blank", json.dig("errors", "key"))
    assert_equal("can't be blank", json.dig("errors", "url"))
  end

  def test_update
    shortcode = shortcodes(:this)
    params = { shortcode: { shortcode: "#{unique_suffix}" } }

    put shortcode_url(shortcode.id), user_authed(params: params)
    assert_response(:ok)
    assert_equal("ok", json["status"])
    assert_equal(shortcode_url(shortcode.id), json["location"])
    assert_equal(shortcode_url(shortcode.id), @response.headers["location"])
  end

  def test_update_with_bad_data
    shortcode = shortcodes(:this)
    params = { shortcode: { key: "" } }

    put shortcode_url(shortcode.id), user_authed(params: params)
    assert_response(:bad_request)
    assert_equal("error", json["status"])
    assert_equal("can't be blank", json.dig("errors", "key"))
  end

  def test_update_with_unknown_shortcode
    params = { user: { password: "new_password" } }

    put shortcode_url("unknown"), user_authed(params: params)
    assert_response(:not_found)
    assert_equal("error", json["status"])
    assert_equal("not found", json.dig("errors", "shortcode"))
  end

  def test_delete
    shortcode = shortcodes(:this)

    delete shortcode_url(shortcode.id), user_authed
    assert_response(:ok)
    assert_equal("ok", json["status"])
  end

  def test_delete_with_unknown_user
    delete shortcode_url("unknown"), user_authed
    assert_response(:not_found)
    assert_equal("error", json["status"])
    assert_equal("not found", json.dig("errors", "shortcode"))
  end

  def test_resolve
    shortcode = shortcodes(:this)

    get resolver_url(shortcode.key)
    assert_redirected_to shortcode.url
  end

  def test_resolve_with_unknown_shortcode
    get resolver_url("unknown")
    assert_response(:not_found)
  end
end
