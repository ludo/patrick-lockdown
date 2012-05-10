# encoding: utf-8

module Lockdown
  class Database
    class << self
      # This is very basic and could be handled better using orm specific
      # functionality, but I wanted to keep it generic to avoid creating 
      # an interface for each the different orm implementations. 
      # We'll see how it works...
      def sync_with_db
        @permissions = Lockdown::Configuration.permission_names
        @user_groups = Lockdown::Configuration.user_group_names

        unless ::Permission.table_exists? && Lockdown.user_group_class.table_exists?
          Lockdown.logger.info ">> Lockdown tables not found.  Skipping database sync."
          return
        end

        create_new_permissions

        delete_extinct_permissions
      
        maintain_user_groups
      end

      # Create permissions not found in the database
      def create_new_permissions
        @permissions.each do |name|
          next if Lockdown::Configuration.permission_assigned_automatically?(name)
          p = ::Permission.find(:first, :conditions => ["name = ?", name])
          unless p
            Lockdown.logger.info ">> Lockdown: Permission not found in db: #{name}, creating."
            ::Permission.create(:name => name)
          end
        end
      end

      # Delete the permissions not found in init.rb
      def delete_extinct_permissions
        db_perms = ::Permission.find(:all).dup
        db_perms.each do |dbp|
          unless @permissions.include?(dbp.name)
            Lockdown.logger.info ">> Lockdown: Permission no longer in init.rb: #{dbp.name}, deleting."
          ug_table = Lockdown.user_groups_hbtm_reference.to_s
          if "permissions" < ug_table
            join_table = "permissions_#{ug_table}"
          else
            join_table = "#{ug_table}_permissions"
          end
            Lockdown.database_execute("delete from #{join_table} where permission_id = #{dbp.id}")
            dbp.destroy
          end
        end
      end

      def maintain_user_groups
        # Create user groups not found in the database
        @user_groups.each do |name|
          unless ug = Lockdown.user_group_class.find(:first, :conditions => ["name = ?", name])
            create_user_group(name)
          else
            # Remove permissions from user group not found in init.rb
            remove_invalid_permissions(ug)

            # Add in permissions from init.rb not found in database
            add_valid_permissions(ug)
          end
        end
      end

      def create_user_group(name)
        Lockdown.logger.info ">> Lockdown: #{Lockdown::Configuration.user_group_model} not in the db: #{name}, creating."
        ug = Lockdown.user_group_class.create(:name => name)
        #Inefficient, definitely, but shouldn't have any issues across orms.
        #
        Lockdown::Configuration.user_group_permissions_names(name).each do |perm|

          if Lockdown::Configuration.permission_assigned_automatically?(perm)
            Lockdown.logger.info  ">> Permission #{perm} cannot be assigned to #{name}.  Already belongs to built in user group (public or protected)."
            raise  InvalidPermissionAssignment, "Invalid permission assignment"
          end

          p = ::Permission.find(:first, :conditions => ["name = ?", perm]) 

          ug_table = Lockdown.user_groups_hbtm_reference.to_s
          if "permissions" < ug_table
            join_table = "permissions_#{ug_table}"
          else
            join_table = "#{ug_table}_permissions"
          end
          Lockdown.database_execute "insert into #{join_table}(permission_id, #{Lockdown.user_group_id_reference}) values(#{p.id}, #{ug.id})"
        end
      end

      def remove_invalid_permissions(ug)
        ug.permissions.each do |perm|
          unless Lockdown::Configuration.user_group_permissions_names(ug.name).include?(perm.name)
            Lockdown.logger.info ">> Lockdown: Permission: #{perm.name} no longer associated to User Group: #{ug.name}, deleting."
            ug.permissions.delete(perm)
          end
        end
      end

      def add_valid_permissions(ug)
        Lockdown::Configuration.user_group_permissions_names(ug.name).each do |perm_name|
          found = false
          # see if permission exists
          ug.permissions.each do |p|
            found = true if p.name == perm_name
          end
          # if not found, add it
          unless found
            Lockdown.logger.info ">> Lockdown: Permission: #{perm_name} not found for User Group: #{ug.name}, adding it."
            p = ::Permission.find(:first, :conditions => ["name = ?", perm_name])
            ug.permissions << p
          end
        end
      end

    end # class block
  end # Database
end #Lockdown
