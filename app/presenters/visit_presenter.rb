class VisitPresenter < SimpleDelegator
  attr_reader :h

  def initialize(model, view_context)
    @h = view_context
    super(model)
  end

  def shortcode
    h.shortcode_url(shortcode_id)
  end

  def as_json(*args)
    super.tap do |hsh|
      hsh.delete("shortcode_id")
      hsh["shortcode"] = shortcode
    end
  end
end

