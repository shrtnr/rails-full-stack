class VisitPresenter < SimpleDelegator
  def initialize(model)
    super(model)
  end

  def shortcode
    Rails.application.routes.url_helpers.shortcode_url(shortcode_id)
  end

  def as_json(*args)
    super.tap do |hsh|
      hsh.delete("shortcode_id")
      hsh["shortcode"] = shortcode
    end
  end
end

