class Visit < ApplicationRecord
  belongs_to :shortcode

  validates :request, presence: true
  validates :target, presence: true
end
