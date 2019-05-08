require 'test_helper'

class ShortcodesControllerTest < ActionDispatch::IntegrationTest
  def test_index_without_creds
    get shortcodes_url, unauthed
    assert_response(:unauthorized)
    assert_equal("user is unauthorized", json["error_message"])
  end

  def test_index
    shortcode = shortcodes(:this)

    get shortcodes_url, user_authed
    assert_response(:ok)
    assert_equal(2, json["total"])
    assert_equal(1, json["page"])
    assert_equal(20, json["per_page"])
    assert_equal(2, json["shortcodes"].length)

    assert_includes(json["shortcodes"].map { |s| s["user_id"] }, shortcode.user.id)
    assert_includes(json["shortcodes"].map { |s| s["key"] }, shortcode.key)
    assert_includes(json["shortcodes"].map { |s| s["url"] }, shortcode.url)
    refute_includes(json["shortcodes"].map { |s| s["key"] }, shortcodes(:other).key)
  end

  def test_index_pagination
    params = Proc.new do 
      unique = unique_suffix
      { key: "#{unique}", url: "https://#{unique}.example.com" }
    end 
    5.times { shortcodes(:this).user.shortcodes.create(params.call) }

    get shortcodes_url(page: 2, per_page: 4), user_authed
    assert_response(:ok)
    assert_equal(7, json["total"])
    assert_equal(2, json["page"])
    assert_equal(4, json["per_page"])
    assert_equal(3, json["shortcodes"].length)
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
    assert_equal("shortcode not found", json["error_message"])
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
    assert_match(%r(^#{shortcodes_url}/.*), @response.headers["location"])
  end

  def test_create_with_bad_data
    params = { shortcode: { x: "x" } } # required param can't be empty
    post shortcodes_url, user_authed(params: params)
    assert_response(:bad_request)
    assert_equal("can't be blank", json.dig("error_messages", "key"))
    assert_equal("can't be blank", json.dig("error_messages", "url"))
  end

  def test_update
    shortcode = shortcodes(:this)
    params = { shortcode: { shortcode: "#{unique_suffix}" } }

    put shortcode_url(shortcode.id), user_authed(params: params)
    assert_response(:ok)
    assert_equal(shortcode_url(shortcode.id), @response.headers["location"])
  end

  def test_update_with_bad_data
    shortcode = shortcodes(:this)
    params = { shortcode: { key: "" } }

    put shortcode_url(shortcode.id), user_authed(params: params)
    assert_response(:bad_request)
    assert_equal("can't be blank", json.dig("error_messages", "key"))
  end

  def test_update_with_unknown_shortcode
    params = { user: { password: "new_password" } }

    put shortcode_url("unknown"), user_authed(params: params)
    assert_response(:not_found)
    assert_equal("shortcode not found", json["error_message"])
  end

  def test_delete
    shortcode = shortcodes(:this)

    delete shortcode_url(shortcode.id), user_authed
    assert_response(:ok)
  end

  def test_delete_with_unknown_user
    delete shortcode_url("unknown"), user_authed
    assert_response(:not_found)
    assert_equal("shortcode not found", json["error_message"])
  end

  def test_resolve
    shortcode = shortcodes(:this)
    visits_before = shortcode.visits.count

    get resolver_url(shortcode.key)
    assert_redirected_to shortcode.url
    refute_equal(visits_before, shortcode.visits.count)

    last_visit = shortcode.visits.last
    assert_equal("127.0.0.1", last_visit.remote_ip)
    assert_equal("http://www.example.com/this", last_visit.request)
    assert_equal("https://this.example.com", last_visit.target)
  end

  def test_resolve_with_unknown_shortcode
    get resolver_url("unknown")
    assert_response(:not_found)
  end
end
