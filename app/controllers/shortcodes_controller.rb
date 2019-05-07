class ShortcodesController < ApiController
  before_action :validate_user!, except: :resolve
  before_action :find_shortcode!, only: %i(show update destroy)

  def index
    @shortcodes = current_user.shortcodes.page(@pagination.page).per(@pagination.per_page)
    total = current_user.shortcodes.count
    render json: { status: :ok, total: total, shortcodes: @shortcodes }.merge(@pagination.to_h),
           status: :ok
  end

  def show
    render json: { status: :ok, shortcode: @shortcode }, status: :ok
  end

  def create
    @shortcode = current_user.shortcodes.new(permitted_params)
    if @shortcode.save
      render json: { status: :ok, location: shortcode_url(@shortcode.id) },
             location: shortcode_url(@shortcode.id), status: :created
    else
      render json: { status: :error, errors: format_errors(@shortcode) }, status: :bad_request
    end
  end

  def update
    if @shortcode.update_attributes(permitted_params)
      render json: { status: :ok, location: shortcode_url(@shortcode.id) },
             location: shortcode_url(@shortcode.id), status: :ok
    else
      render json: { status: :error, errors: format_errors(@shortcode) }, status: :bad_request
    end
  end

  def destroy
    @shortcode.delete
    render json: { status: :ok }, status: :ok
  end

  def resolve
    @shortcode = Shortcode.find_by!(key: params[:key])

    @shortcode.visits.create!(
      remote_ip: request.remote_ip,
      request: request.original_url,
      target: @shortcode.url,
      referrer: request.referrer,
      user_agent: request.user_agent 
    )

    redirect_to @shortcode.url 
  rescue ActiveRecord::RecordNotFound
    render json: { status: :error, errors: { "shortcode" => "not found" } }, status: :not_found
  end

private

  def find_shortcode!
    @shortcode = current_user.shortcodes.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { status: :error, errors: { "shortcode" => "not found" } }, status: :not_found
  end

  def permitted_params
    params.require(:shortcode).permit(:key, :url)
  end
end
