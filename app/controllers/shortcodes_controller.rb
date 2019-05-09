# frozen_string_literal: true

class ShortcodesController < ApplicationController
  before_action :validate_user!, except: :resolve
  before_action :find_shortcode!, only: %i[show update destroy]

  def index
    @shortcodes = current_user.shortcodes
                              .page(@pagination.page)
                              .per(@pagination.per_page)
                              .map { |sc| ShortcodePresenter.new(sc) }
    total = current_user.shortcodes.count
    render json: { total: total, shortcodes: @shortcodes }.merge(@pagination.to_h),
           status: :ok
  end

  def show
    render json: { shortcode: ShortcodePresenter.new(@shortcode) }, status: :ok
  end

  def create
    @shortcode = current_user.shortcodes.new(permitted_params)
    if @shortcode.save
      head :created, location: shortcode_url(@shortcode.id)
    else
      render json: { error_messages: format_errors(@shortcode) }, status: :bad_request
    end
  end

  def update
    if @shortcode.update_attributes(permitted_params)
      head :ok, location: shortcode_url(@shortcode.id), status: :ok
    else
      render json: { error_messages: format_errors(@shortcode) }, status: :bad_request
    end
  end

  def destroy
    @shortcode.delete
    head :ok
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
    render json: { error_message: 'shortcode not found' }, status: :not_found
  end

private

  def find_shortcode!
    @shortcode = current_user.shortcodes.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error_message: 'shortcode not found' }, status: :not_found
  end

  def permitted_params
    params.require(:shortcode).permit(:key, :url)
  end
end
