class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token

private

  def format_errors(entity)
    entity.errors.to_hash.each.with_object({}) { |(k, v), err| err[k] = v.join("; ") }
  end
end
