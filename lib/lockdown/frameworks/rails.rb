# encoding: utf-8

require File.join(File.dirname(__FILE__), "rails", "controller")
require File.join(File.dirname(__FILE__), "rails", "view")

module Lockdown
  module Frameworks
    module Rails
      class << self
        def included(mod)
          mod.extend Lockdown::Frameworks::Rails::Environment
          mixin
        end
        
        def mixin
          mixin_controller

          Lockdown.view_helper.class_eval do
            include Lockdown::Frameworks::Rails::View
          end

          Lockdown::Configuration.class_eval do 
            def self.skip_sync?
              skip_db_sync_in.include?(::Rails.env)
            end
          end
        end

        def mixin_controller(klass = Lockdown.controller_parent)
          klass.class_eval do
            include Lockdown::Session
            include Lockdown::Frameworks::Rails::Controller::Lock
          end

          klass.helper_method :authorized?

          klass.hide_action(:set_current_user, :configure_lockdown, :check_request_authorization)

          klass.before_filter do |c|
            c.set_current_user
            c.configure_lockdown
            c.check_request_authorization
          end

          klass.filter_parameter_logging :password, :password_confirmation
      
          klass.rescue_from SecurityError, :with => proc{|e| ld_access_denied(e)}
        end
      end # class block

      module Environment

        def project_root
          ::RAILS_ROOT
        end

        def view_helper
          ::ActionView::Base 
        end

        # cache_classes is true in production and testing, need to
        # modify the ApplicationController 
        def controller_parent
          if caching?
            ApplicationController
          else
            ActionController::Base
          end
        end
        
        def caching?
          ::Rails.configuration.cache_classes
        end
      end
    end # Rails
  end # Frameworks
end # Lockdown
