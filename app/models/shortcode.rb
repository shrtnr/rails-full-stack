class Shortcode < ApplicationRecord
  belongs_to :user
  has_many :visits

  validates :key, presence: true
  validates :url, presence: true
end
