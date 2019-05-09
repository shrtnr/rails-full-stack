class ShortcodePresenter < SimpleDelegator
  attr_reader :h

  def initialize(model, view_context)
    @h = view_context
    super(model)
  end

  def user
    h.user_url(user_id)
  end

  def as_json(*args)
    super.tap do |hsh|
      hsh.delete("user_id")
      hsh["user"] = user
    end
  end
end
