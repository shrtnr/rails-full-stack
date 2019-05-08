require 'test_helper'

class VisitsControllerTest < ActionDispatch::IntegrationTest
  def test_index_without_creds
    shortcode = shortcodes(:this)
    get shortcode_visits_url(shortcode.id), unauthed
    assert_response(:unauthorized)
    assert_equal("user is unauthorized", json["error_message"])
  end

  def test_index_with_bad_shortcode
    shortcode = shortcodes(:this)
    get shortcode_visits_url("unknown"), user_authed
    assert_response(:not_found)
    assert_equal("shortcode not found", json["error_message"])
  end

  def test_index
    visit = visits(:one)

    get shortcode_visits_url(visit.shortcode.id), user_authed
    assert_response(:ok)
    assert_equal(2, json["total"])
    assert_equal(1, json["page"])
    assert_equal(20, json["per_page"])
    assert_equal(2, json["visits"].length)

    assert_includes(json["visits"].map { |s| s["shortcode_id"] }, visit.shortcode.id) 
    assert_includes(json["visits"].map { |s| s["remote_ip"] }, visit.remote_ip)
    assert_includes(json["visits"].map { |s| s["request"] }, visit.request)
    assert_includes(json["visits"].map { |s| s["target"] }, visit.target)
    assert_includes(json["visits"].map { |s| s["referrer"] }, visit.referrer)
    assert_includes(json["visits"].map { |s| s["user_agent"] }, visit.user_agent)
  end

  def test_index_pagination
    visit = visits(:one)

    attrs = visit.attributes.slice("remote_ip", "request", "target", "referrer", "user_agent")
    5.times { visit.shortcode.visits.create(attrs) }

    get shortcode_visits_url(visit.shortcode.id, page: 2, per_page: 4), user_authed
    assert_response(:ok)
    assert_equal(2, json["page"])
    assert_equal(4, json["per_page"])
    assert_equal(3, json["visits"].length)
  end
end
