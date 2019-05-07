class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :handle_pagination_attributes!

  Pagination = Struct.new(:page, :per_page)

private

  def format_errors(entity)
    entity.errors.to_hash.each.with_object({}) { |(k, v), err| err[k] = v.join("; ") }
  end

  def handle_pagination_attributes!
    @pagination = Pagination.new((params[:page] || 1).to_i, (params[:per_page] || 20).to_i)
  end
end
