require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def test_as_json
    user = User.new
    assert_equal(%i(admin created_at email id updated_at), user.as_json.keys.sort)
  end

  def test_to_jwt
    user = User.new(email: "test@example.com")
    payload = JWT.decode(user.to_jwt, nil, false) # skip validation
    assert_equal("test@example.com", payload.first["sub"])
  end

  def test_from_jwt
    user = users(:user)
    jwt = user.to_jwt

    user_from_jwt = User.from_jwt(jwt)
    assert_equal(user, user_from_jwt)
  end

  def test_from_jwt_with_bogus_jwt
    assert_nil(User.from_jwt("BOGUS"))
  end

end
