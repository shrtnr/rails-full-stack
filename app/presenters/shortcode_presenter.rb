class ShortcodePresenter < SimpleDelegator
  def initialize(model)
    super(model)
  end

  def user
    Rails.application.routes.url_helpers.user_url(user_id)
  end

  def as_json(*args)
    super.tap do |hsh|
      hsh.delete("user_id")
      hsh["user"] = user
    end
  end
end
