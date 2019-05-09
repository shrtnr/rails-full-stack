# frozen_string_literal: true

class Shortcode < ApplicationRecord
  belongs_to :user
  has_many :visits

  validates :key, presence: true, uniqueness: true
  validates :url, presence: true
end
