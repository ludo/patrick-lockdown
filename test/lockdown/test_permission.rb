require 'helper'

class TestLockdownPermission < MiniTest::Unit::TestCase

  def setup
    @permission = Lockdown::Permission.new(:my_account)
  end

  def test_initializer_sets_correct_state
    assert_equal 'my_account', @permission.name
    assert_equal [], @permission.resources
    assert_equal false, @permission.public?
    assert_equal false, @permission.protected?
  end

  def test_setting_public
    @permission.is_public
    assert_equal true, @permission.public?
    assert_equal false, @permission.protected?
  end

  def test_setting_protected
    @permission.is_protected
    assert_equal true, @permission.protected?
    assert_equal false, @permission.public?
  end

  def test_resource
    @permission.resource(:users)

    resource = @permission.resources.first
    assert_equal resource.name, 'users'
  end

  def test_alias_controller
    @permission.controller(:users)

    controller = @permission.controllers.first
    assert_equal controller.name, 'users'
  end

  def test_resource_with_block
    @permission.resource(:users) do
      except :destroy
    end

    resource = @permission.resources.first
    assert_equal resource.exceptions, ['destroy']
  end

  def test_alias_controller_with_block
    @permission.controller(:users) do
      except :destroy
    end

    controller = @permission.controllers.first
    assert_equal controller.exceptions, ['destroy']
  end

  def test_regex_pattern
    @permission.resource(:users)

    assert_equal @permission.regex_pattern, "(\/users(\/.*)?)"
  end

  def test_regex_pattern_with_multiple_resources
    @permission.resource(:users)
    @permission.resource(:posts)

    assert_equal @permission.regex_pattern, "(\/users(\/.*)?)|(\/posts(\/.*)?)"
  end
end

