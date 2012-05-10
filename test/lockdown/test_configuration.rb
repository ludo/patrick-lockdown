require 'helper'

class Authorization
  include Lockdown::Access
end

class TestLockdownConfiguration < MiniTest::Unit::TestCase

  def setup
    @config = Lockdown::Configuration
  end

  def teardown
    Lockdown::Configuration.reset
  end

  def test_initial_state
    assert_equal false, @config.configured
    assert_equal "", @config.public_access
    assert_equal "", @config.protected_access
    assert_equal [], @config.permissions
    assert_equal [], @config.user_groups

    assert_equal :current_user_id, @config.who_did_it
    assert_equal 1, @config.default_who_did_it

    assert_equal "/", @config.access_denied_path
    assert_equal "/", @config.successful_login_path
    assert_equal false, @config.logout_on_access_violation

    assert_equal "|", @config.link_separator

    assert_equal "UserGroup", @config.user_group_model
    assert_equal "User", @config.user_model

    assert_equal ['test'] , @config.skip_db_sync_in
    assert_nil @config.subdirectory
  end

  def test_authenticated_access
    Authorization.permission('home')
    Authorization.permission('faq')
    Authorization.permission('users')

    Authorization.public_access('home', 'faq')
    Authorization.protected_access('users')

    assert_equal "(/home(/.*)?)|(/faq(/.*)?)|(/users(/.*)?)", @config.authenticated_access
  end

  def test_permission
    Authorization.permission('home')
    Authorization.permission('faq')

    perm  = Lockdown::Permission.new('home')

    assert_equal perm.name, @config.permission('home').name

    assert_raises(Lockdown::PermissionNotFound){ @config.permission('delta') }
  end

  def test_make_permission_public
    Authorization.permission('home')

    @config.make_permission_public('home')

    perm = @config.permission('home')

    assert_equal true, perm.public?
  end

  def test_has_permission
    Authorization.permission('home')
    Authorization.permission('faq')
    Authorization.permission('about')

    perm  = Lockdown::Permission.new('home')
    perm2 = Lockdown::Permission.new('homey')

    assert_equal true, @config.has_permission?(perm)

    assert_equal false, @config.has_permission?(perm2)
  end

  def test_permission_names
    Authorization.permission('home')
    Authorization.permission('faq')
    Authorization.permission('about')

    assert_equal 'about', @config.permissions.pop.name
    assert_equal 'faq', @config.permissions.pop.name
    assert_equal 'home', @config.permissions.pop.name

    assert_equal true, @config.permissions.empty?
  end

  def test_permission_assigned_automatically
    Authorization.permission('home')
    Authorization.permission('faq')
    Authorization.permission('users')

    Authorization.public_access('home', 'faq')

    assert_equal true, @config.permission_assigned_automatically?('home')
    assert_equal true, @config.permission_assigned_automatically?('faq')
    assert_equal false, @config.permission_assigned_automatically?('users')
  end

  def test_user_group
    Authorization.permission('home')
    Authorization.permission('faq')

    Authorization.user_group 'all', 'home', 'faq'

    ug =  @config.user_group('all')

    assert_equal 'faq', ug.permissions.pop.name
    assert_equal 'home',ug.permissions.pop.name
  end

  def test_maybe_add_user_group
    Authorization.permission('home')
    Authorization.permission('faq')

    Authorization.user_group 'all', 'home', 'faq'
    groups_1 = @config.user_groups

    Authorization.user_group 'all', 'home', 'faq'
    groups_2 = @config.user_groups

    assert_equal groups_1, groups_2
  end

  def test_find_or_create_user_group
    Authorization.permission('home')
    Authorization.permission('faq')
    Authorization.permission('about')

    Authorization.user_group 'testone', 'home', 'faq', 'about'

    ug = @config.find_or_create_user_group('testone')

    assert_equal 'testone', ug.name

    assert_equal 'about', ug.permissions.pop.name
    assert_equal 'faq', ug.permissions.pop.name
    assert_equal 'home', ug.permissions.pop.name

    assert_equal true, ug.permissions.empty?

    ug2 = @config.find_or_create_user_group('testtwo')

    assert_equal 'testtwo', ug2.name
    assert_equal true, ug2.permissions.empty?
  end

  def test_user_group_names
    Authorization.permission('home')
    Authorization.permission('faq')
    Authorization.permission('about')

    Authorization.user_group 'testone', 'home'
    Authorization.user_group 'testtwo', 'faq', 'about'

    assert_equal 'testtwo', @config.user_groups.pop.name
    assert_equal 'testone', @config.user_groups.pop.name

    assert_equal true, @config.user_groups.empty?
  end

  def test_user_group_permission_names
    Authorization.permission('home')
    Authorization.permission('faq')
    Authorization.permission('about')

    Authorization.user_group 'testone', 'home'
    Authorization.user_group 'testtwo', 'faq', 'about'

    assert_equal ['home'], @config.user_group_permissions_names('testone')
    assert_equal ['faq', 'about'], @config.user_group_permissions_names('testtwo')
  end

  def test_access_rights_for_permissions
    Authorization.permission('home')
    Authorization.permission('faq')
    Authorization.permission('about')

    assert_equal "((/home(/.*)?))|((/faq(/.*)?))|((/about(/.*)?))",
      @config.access_rights_for_permissions('home', 'faq', 'about')
  end

  def test_skip_sync?
    assert_equal true, @config.skip_sync?
  end
end
