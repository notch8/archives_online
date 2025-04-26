# frozen_string_literal: true

require_relative 'relator_service'

##
# A utility class to normalize creators by joining
# the role and creator name into a hash object containing the
# unique roles as keys and an array of one or more creator names
module Arclight
  class CreatorRoles
    # @param [Array > Hash] [{creator: 'creator name', role: 'role name'}]
    def initialize(creator_roles:, logger: nil)
      @creator_roles = creator_roles
      @result = []
      @logger = logger
    end

    # @return [String] the normalized creator/role hash string
    def to_s
      normalize
    end

    private

    attr_reader :creator_roles, :result, :logger

    def normalize
      @creator_roles.each do |creator_role|
        creator = creator_role[:creator]
        role = creator_role[:role] || 'creator'
        combine_roles(creator, role)
      end
      translate_roles(@result)
    end

    def combine_roles(creator, role)
      # Check if the role already exists as a key in any hash within @result
      existing_entry = @result.find { |hash| hash.key?(role) }
      if existing_entry
        # If the role exists, add the creator to the array of creators for that role
        existing_entry[role] << creator
      else
        # If the role doesn't exist, create a new hash with the role as the key
        @result << { role => [creator] }
      end
    end

    def translate_roles(results)
      result_array = []

      results.each do |role_hash|
        key = role_hash.keys.first
        translated_role = RelatorService.for(key) || key.titleize
        role_hash[translated_role] = role_hash.delete(key)
        result_array << role_hash.to_json
      end.to_json
      result_array
    end
  end
end
