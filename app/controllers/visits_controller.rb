class VisitsController < ApiController
  before_action :validate_user!
  before_action :find_shortcode!

  def index
    @visits = @shortcode.visits.page(@pagination.page).per(@pagination.per_page)
    total = @shortcode.visits.count

    render json: { status: :ok, total: total, visits: @visits}.merge(@pagination.to_h), 
           status: :ok
  end

private

  def find_shortcode!
    @shortcode = current_user.shortcodes.find(params[:shortcode_id])
  rescue ActiveRecord::RecordNotFound
    render json: { status: :error, errors: { "shortcode" => "not found" } }, status: :not_found
  end
end
