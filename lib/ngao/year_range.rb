# frozen_string_literal: true

require 'arclight/year_range'

module Ngao
  class YearRange < Arclight::YearRange
    # @param [String] `dates` in the form YYYY/YYYY
    # @return [Array<Integer>] the set of years in the given range
    def parse_range(dates)
      return if dates.blank?

      start_year, end_year = dates.split('/').map { |date| to_year_from_iso8601(date) }
      return [start_year] if end_year.blank?
      # Original in Arclight checks that date ranges can't be larger than 1000 years, we don't want that in NGAO
      # raise ArgumentError, "Range is too large: #{dates}" if (end_year - start_year) > 1000
      raise ArgumentError, "Range is inverted: #{dates}" unless start_year <= end_year

      (start_year..end_year).to_a
    end
  end
end
