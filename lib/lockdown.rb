# encoding: utf-8

$:.unshift File.dirname(__FILE__)

require 'logger'

require File.join("lockdown", "errors")
require File.join("lockdown", "helper")
require File.join("lockdown", "configuration")
require File.join("lockdown", "session")
require File.join("lockdown", "delivery")
require File.join("lockdown", "resource")
require File.join("lockdown", "permission")
require File.join("lockdown", "user_group")
require File.join("lockdown", "access")
require File.join("lockdown", "database")


module Lockdown
  extend Lockdown::Helper

  class << self
    attr_accessor :logger

    # @return the version string for the library.
    def version
      '2.0.4'
    end

    def rails_mixin
      require File.join("lockdown", "frameworks", "rails")
      include Lockdown::Frameworks::Rails

      require File.join("lockdown", "orms", "active_record")
      include Lockdown::Orms::ActiveRecord
    end

  end # class block

  self.logger = Logger.new(STDOUT)

end # Lockdown
