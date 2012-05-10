# encoding: utf-8

module Lockdown
  class Delivery
    class << self
      # @return [true|false] if the given path is allowed
      def allowed?(path, access_rights = nil)
        begin
          ::Authorization.configure
        rescue NameError
        end

        access_rights ||= Lockdown::Configuration.public_access

        access_rights_regex = Lockdown.regex(access_rights)

        path += "/" unless path =~ /\/$/
        path = "/" + path unless path =~ /^\//

        if (access_rights_regex =~ path) == 0
          return true 
        end

        return false
      end
    end # class block
  end # Delivery
end # Lockdown
