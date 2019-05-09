class ApplicationController < ActionController::API
  before_action :handle_pagination_attributes!

  Pagination = Struct.new(:page, :per_page)

private

  def format_errors(entity)
    entity.errors.to_hash.each.with_object({}) { |(k, v), err| err[k] = v.join("; ") }
  end

  def handle_pagination_attributes!
    @pagination = Pagination.new((params[:page] || 1).to_i, (params[:per_page] || 20).to_i)
  end

  def current_user
    auth_header = request.headers[:authorization] || ""
    if m = auth_header.match(/^bearer (.*)$/i)
      User.from_jwt(m[1])
    end
  end

  def validate_admin!
    return true if current_user && current_user.admin?
    render json: { error_message: "user is unauthorized" }, status: :unauthorized
    false
  end

  def validate_user!
    return true if current_user
    render json: { error_message: "user is unauthorized" }, status: :unauthorized
    false
  end
end
