# encoding: utf-8

module Lockdown
  module Configuration
    class << self
      # Flag to determine if configuration method has been executed
      # Default false
      attr_accessor :configured
      # Regex string of paths that are publicly accessible.
      # Default "\/"
      attr_accessor :public_access
      # Array of paths that are restricted to an authenticated user.
      # Default ""
      attr_accessor :protected_access
      # Array of permission objects that defines the access to the application.
      # Default []
      attr_accessor :permissions
      # Array of user group objects
      # Default []
      attr_accessor :user_groups
      # Method used to get the id of the user responsible for
      # the current action.
      # Default :current_user_id
      attr_accessor :who_did_it
      # User id to associate to system actions
      # Default 1
      attr_accessor :default_who_did_it
      # Path to redirect to if access is denied.
      # Default: '/'
      attr_accessor :access_denied_path
      # Redirect to path on successful login
      # Default "/"
      attr_accessor :successful_login_path
      # Logout user if attempt to access restricted resource
      # Default false
      attr_accessor :logout_on_access_violation
      # When using the links helper, this character will be
      # used to separate the links.
      # Default "|"
      attr_accessor :link_separator
      # The model used to represent the grouping of permisssion. Common
      # choices are 'Role' and 'UserGroup'.
      # Default "UserGroup"
      attr_accessor :user_group_model
      # The model used to represent the user. Common choices
      # are 'User' and 'Person'.
      # Default "User"
      attr_accessor :user_model
      # Which environments Lockdown should not sync with db
      # Default ['test']
      attr_accessor :skip_db_sync_in
      # If deploying to a subdirectory, set that here. Defaults to nil
      # Notice: Do not add leading or trailing slashes, Lockdown will handle this
      attr_accessor :subdirectory
      #
      # Set defaults.
      def reset
        @configured                   = false
        @public_access                = ""
        @protected_access             = ""
        @permissions                  = []
        @user_groups                  = []

        @who_did_it                   = :current_user_id
        @default_who_did_it           = 1

        @access_denied_path           = "/"
        @successful_login_path        = "/"
        @logout_on_access_violation   = false

        @link_separator               = "|"

        @user_group_model             = "UserGroup"
        @user_model                   = "User"

        @skip_db_sync_in              = ['test']
      end

      # @return [String] concatentation of public_access + "|" + protected_access
      def authenticated_access
        public_access + "|" + protected_access
      end

      # @param [String,Symbol] name permission name
      # @return Lockdown::Permission object
      def permission(name)
        name = name.to_s
        perm = permissions.detect{|perm| name == perm.name}
        raise Lockdown::PermissionNotFound.new("Permission: #{name} not found") unless perm
        perm
      end

      # Defines the permission as public
      # @param [String,Symbol] name permission name
      def make_permission_public(name)
        permission(name).is_public
      end

      # Defines the permission as protected
      # @param [String,Symbol] name permission name
      def make_permission_protected(name)
        permission(name).is_protected
      end

      # @return Array of permission names
      def permission_names
        permissions.collect{|p| p.name}
      end

      # @param [Lockdown::Permission] permission Lockdown::Permission object
      # @return [true|false] true if object exists with same name
      def has_permission?(permission)
        permissions.any?{|p| permission.name == p.name}
      end

      # @param [String|Symbol] name permission name
      # @return [true|false] true if permission is either public or protected
      def permission_assigned_automatically?(name)
        name = name.to_s

        perm = permission(name)

        perm.public? || perm.protected?
      end

      # @param [String,Symbol] name user group name
      # @return [Lockdown::UserGroup] object
      def user_group(name)
        name = name.to_s
        user_groups.detect{|ug| name == ug.name}
      end

      def maybe_add_user_group(group)
        @user_groups << group unless user_group_names.include?(group.name)
      end

      # @return [Lockdown::UserGroup]
      def find_or_create_user_group(name)
        name = name.to_s
        user_group(name) || Lockdown::UserGroup.new(name)
      end

      # @return [Array] names
      def user_group_names
        user_groups.collect{|ug| ug.name}
      end

      # @param [String] name user group name
      # @return [Array] permissions names
      def user_group_permissions_names(name)
        user_group(name).permissions.collect{|p| p.name}
      end

      # @return [True|False] true if user has 'Administrators' group
      def administrator?(user)
        user_has_user_group?(user, Lockdown.administrator_group_name)
      end

      # @param [User] user User object you want to make an administrator
      def make_user_administrator(user)
        user_groups = user.send(Lockdown.user_groups_hbtm_reference)
        user_groups << Lockdown.user_group_class.
          find_or_create_by_name(Lockdown.administrator_group_name)
      end


      # @param [User, String] user,name  user model, name of user group
      # @return [True|False] true if user has user group with name
      def user_has_user_group?(user, name)
        user_groups = user.send(Lockdown.user_groups_hbtm_reference)
        user_groups.any?{|ug| name == ug.name}
      end

      # @return [Regex]
      def access_rights_for_user(user)
        return unless user
        return Lockdown::Resource.regex if administrator?(user)

        user_groups = user.send(Lockdown.user_groups_hbtm_reference)

        permission_names = []

        user_groups.each do |ug|
          ug.permissions.each do |p|
            permission_names << p.name
          end
        end

        if permission_names.empty?
          authenticated_access
        else
          authenticated_access + "|" + access_rights_for_permissions(*permission_names)
        end
      end

      # @param [Array(String)] names permission names
      # @return [String] combination of regex_patterns from permissions
      def access_rights_for_permissions(*names)
        names.collect{|name| "(#{permission(name).regex_pattern})"}.join('|')
      end

      def skip_sync?
        true
      end
    end # class block

    self.reset
  end # Configuration
end # Lockdown
