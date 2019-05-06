class Shortcode < ApplicationRecord
  belongs_to :user
  has_many :visits

  validates :shortcode, presence: true
  validates :url, presence: true
  validates :allow_params, inclusion: [true, false]
end
