# encoding: utf-8

require 'active_support/core_ext'

module Lockdown
  module Helper
    # @return [Regexp] with \A \z boundaries
    def regex(string)
      Regexp.new(/\A#{string}\z/)
    end

    def administrator_group_name
      'Administrators'
    end

    def user_group_class
      eval("::#{Lockdown::Configuration.user_group_model}")
    end

    def user_groups_hbtm_reference
      Lockdown::Configuration.user_group_model.underscore.pluralize.to_sym
    end

    def user_group_id_reference
      Lockdown::Configuration.user_group_model.underscore + "_id"
    end

    def user_class
      eval("::#{Lockdown::Configuration.user_model}")
    end

    def users_hbtm_reference
      Lockdown::Configuration.user_model.underscore.pluralize.to_sym
    end

    def user_id_reference
      Lockdown::Configuration.user_model.underscore + "_id"
    end
  end
end
