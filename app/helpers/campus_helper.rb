# frozen_string_literal: true

module CampusHelper
  include ActiveSupport::Concern

  CAMPUSES = {
    'US-InU' => 'Indiana University Bloomington',
    'US-InU-Sb' => 'Indiana University South Bend',
    'US-InU-Se' => 'Indiana University Southeast',
    'US-inrmiue' => 'Indiana University East',
    'US-InU-K' => 'Indiana University Kokomo',
    'US-iniu' => 'Indiana University Indianapolis',
    'US-InU-N' => 'Indiana University Northwest'
  }.freeze

  def convert_campus_id(value)
    CAMPUSES[value] || 'Indiana University'
  end

  def campus_image(campus)
    "#{campus}.jpg"
  end
end
