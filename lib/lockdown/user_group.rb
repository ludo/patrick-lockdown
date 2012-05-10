# encoding: utf-8

module Lockdown
  class UserGroup
    # Name of permission
    attr_accessor :name
    # Array of permission objects that define the user group
    attr_accessor :permissions

    # @param [String,Symbol] name permission reference. 
    def initialize(name)
      @name = name.to_s
      @permissions = []
    end
  end # Permission
end # Lockdown
