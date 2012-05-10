require 'helper'

class TestLockdownAccess < MiniTest::Unit::TestCase
  include Lockdown::Access

  def teardown
    Lockdown::Configuration.reset
  end

  def test_model_responds_to_permission
    assert_respond_to self, :permission
  end

  def test_permission_with_single_resource
    perm = permission(:my_perm) do 
              resource :my_resource
           end

    resource = perm.resources.first
    assert_equal 'my_resource', resource.name
    assert_equal "\/my_resource(\/.*)?", resource.regex_pattern
  end

  def test_permission_without_block
    perm = permission(:users) 

    resource = perm.resources.first
    assert_equal 'users', resource.name
    assert_equal "\/users(\/.*)?", resource.regex_pattern
  end

  def test_public_access
    permission(:site)
    public_access :site

    assert_equal Lockdown::Configuration.public_access, "(\/site(\/.*)?)"
  end

  def test_public_access_with_multiple_permissions
    permission(:site)
    permission(:registration)
    permission(:view_posts)
    public_access :site, :registration, :view_posts

    assert_equal Lockdown::Configuration.public_access, 
      "(\/site(\/.*)?)|(\/registration(\/.*)?)|(\/view_posts(\/.*)?)"
  end

  def test_protected_access
    permission(:my_account)
    protected_access :my_account

    assert_equal Lockdown::Configuration.protected_access, "(\/my_account(\/.*)?)"
  end

  def test_protected_access_with_multiple_permissions
    permission(:my_account)
    permission(:edit_posts)
    protected_access :my_account, :edit_posts

    assert_equal Lockdown::Configuration.protected_access, 
      "(\/my_account(\/.*)?)|(\/edit_posts(\/.*)?)"
  end

  def test_user_group
    permission(:site)
    permission(:registration)
    permission(:view_posts)
    user_group(:all, :site, :registration, :view_posts)

    ug =  Lockdown::Configuration.find_or_create_user_group(:all)

    assert_equal 'all', ug.name

    assert_equal 'view_posts', ug.permissions.pop.name
    assert_equal 'registration', ug.permissions.pop.name
    assert_equal 'site', ug.permissions.pop.name
  end

end
