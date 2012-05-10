# encoding: utf-8

module Lockdown
  class Permission
    # Name of permission
    attr_accessor :name
    # Array of resource objects that define the access rights for this permission
    attr_reader :resources

    # @param [String,Symbol] name permission reference. 
    def initialize(name)
      @name       = name.to_s
      @resources  = []
      @ispublic     = false
      @isprotected  = false
    end

    # @param [String,Symbol] name resource reference. 
    # @return new resource 
    def resource(name, &block)
      resource =  Lockdown::Resource.new(name)
      resource.instance_eval(&block) if block_given?
      @resources << resource
      resource
    end

    alias_method :controller, :resource

    def controllers
      @resources
    end

    def is_public
      @ispublic     = true
      @isprotected  = false
    end

    def public?
      @ispublic
    end

    def is_protected
      @isprotected  = true
      @ispublic     = false 
    end

    def protected?
      @isprotected
    end

    # @return String representing all resources defining this permission
    def regex_pattern
      resources.collect{|r| "(#{r.regex_pattern})"}.join("|")
    end
  end # Permission
end # Lockdown
