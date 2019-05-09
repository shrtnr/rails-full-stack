# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

private

  def unique_suffix
    (Time.now.to_f * 1000).to_i.to_s(36)
  end
end

class ActionDispatch::IntegrationTest
private # rubocop:disable Layout/IndentationWidth -- rubocop#6861

  def json
    JSON.parse(@response.body)
  end

  def user_authed(**options)
    {
      as: :json,
      headers: { 'Authorization' => "Bearer #{users(:user).to_jwt}" }
    }.merge(options)
  end

  def admin_authed(**options)
    {
      as: :json,
      headers: { 'Authorization' => "Bearer #{users(:admin).to_jwt}" }
    }.merge(options)
  end

  def unauthed(**options)
    { as: :json }.merge(options)
  end
end
