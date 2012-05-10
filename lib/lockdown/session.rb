# encoding: utf-8

module Lockdown
  module Session


    def add_lockdown_session_values(user = nil)
      user ||= current_user

      if user
        session[:access_rights] = Lockdown::Configuration.access_rights_for_user(user)
        session[:current_user_id] = user.id
      else
        session[:access_rights] = Lockdown::Configuration.public_access
      end
    end

    # Tests for current_user_id > 0
    # @return [True|False] 
    def logged_in?
      current_user_id.to_i > 0
    end

    # @return session value of current_user_id
    def current_user_id
      session[:current_user_id]
    end

    # Returns true if the permission's regex_pattern is 
    # in session[:access_rights]
    # @param [String] name permission name
    # @return [True|False] 
    def access_in_perm?(name)
      if perm = Lockdown::Configuration.permission(name)
        return session_access_rights.include?(perm.regex_pattern)
      end
      false
    end

    def session_access_rights
      session[:access_rights].to_s
    end

    def reset_lockdown_session
      [:expiry_time, :current_user_id, :access_rights].each do |val|
        session[val] = nil if session[val]
      end
    end 
  end # Session
end # Lockdown
