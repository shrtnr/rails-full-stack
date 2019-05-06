if Rails.env.development?
  admin = User.create(email: "admin@example.com", admin: true, password: "password", password_confirmation: "password")
  admin.shortcodes.create(shortcode: "abc", url: "https://www.google.com", allow_params: false)
  admin.shortcodes.create(shortcode: "def", url: "https://www.bing.com", allow_params: false)
end
