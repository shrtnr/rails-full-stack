class UsersController < ApiController
  before_action :validate_admin!, except: %i(auth show)
  before_action :find_user!, only: %i(show update destroy)

  def index
    @users = User.all.page(@pagination.page).per(@pagination.per_page)
    total = User.count
    render json: { status: :ok, total: total, users: @users }.merge(@pagination.to_h), 
           status: :ok
  end

  def show
    render json: { status: :ok, user: @user }, status: :ok
  end

  def create
    @user = User.new(permitted_params)
    if @user.save
      render json: { status: :ok, location: user_url(@user.id) },
             location: user_url(@user.id), status: :created
    else
      render json: { status: :error, errors: format_errors(@user) }, status: :bad_request
    end
  end

  def update
    if @user.update_attributes(permitted_params)
      render json: { status: :ok, location: user_url(@user.id) },
             location: user_url(@user.id), status: :ok
    else
      render json: { status: :error, errors: format_errors(@user) }, status: :bad_request
    end
  end

  def destroy
    @user.delete
    render json: { status: :ok }, status: :ok
  end

  def auth
    @user = User.find_by(email: permitted_auth_params[:email])
    if @user && @user.authenticate(permitted_auth_params[:password])
      render json: { status: :ok, token: @user.to_jwt}, status: :ok
    else
      render json: { status: :error, errors: { "user" => "unauthorized" } }, status: :unauthorized
    end
  end

private

  def find_user!
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { status: :error, errors: { "user" => "not found" } }, status: :not_found
  end

  def permitted_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def permitted_auth_params
    params.permit(:email, :password)
  end
end
