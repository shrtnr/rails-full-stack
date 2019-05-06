if Rails.env.development?
  admin = User.create(email: "admin@example.com", admin: true, password: "password", password_confirmation: "password")
  admin.shortcodes.create(key: "abc", url: "https://www.google.com")
  admin.shortcodes.create(key: "def", url: "https://www.bing.com")
end
