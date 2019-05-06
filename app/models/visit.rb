class Visit < ApplicationRecord
  belongs_to :shortcode

  validates :remote_ip, presence: true
  validates :request, presence: true
  validates :referrer, presence: true
  validates :user_agent, presence: true
end
