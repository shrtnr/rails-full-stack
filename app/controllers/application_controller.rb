class ApplicationController < ActionController::Base

private

  def current_user
    auth_header = request.headers[:authorization] || ""
    if m = auth_header.match(/^bearer (.*)$/i)
      User.from_jwt(m[1])
    end
  end

  def validate_admin!
    return true if current_user && current_user.admin?

    render json: { status: :error, errors: { "admin" => "unauthorized" } },
           status: :unauthorized
    false
  end

  def validate_user!
    return true if current_user

    render json: { status: :error, errors: { "user" => "unauthorized" } },
           status: :unauthorized
    false
  end
end
