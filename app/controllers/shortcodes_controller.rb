class ShortcodesController < ApiController
  before_action :validate_user!, except: :resolve
  before_action :find_shortcode!, only: %i(show update destroy)

  def index
    @shortcodes = current_user.shortcodes
    render json: { status: :ok, shortcodes: @shortcodes }, status: :ok
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
      errors = @shortcode.errors.to_hash.each.with_object({}) do |(k, v), err|
        err[k] = v.join("; ")
      end
      render json: { status: :error, errors: errors }, status: :bad_request
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
    @shortcode = Shortcode.find_by!(shortcode: params[:shortcode])
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
    params.require(:shortcode).permit(:shortcode, :url, :allow_params)
  end
end
