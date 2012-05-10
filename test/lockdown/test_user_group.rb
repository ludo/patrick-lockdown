require 'helper'

class TestLockdownUserGroup < MiniTest::Unit::TestCase

  def setup
    @user_group = Lockdown::UserGroup.new(:managers)
    @user_group.permissions << Lockdown::Permission.new(:users)
    @user_group.permissions << Lockdown::Permission.new(:accounts)
  end

  def test_initializer_sets_correct_state
    assert_equal 'managers', @user_group.name
    assert_equal 'accounts', @user_group.permissions.pop.name
    assert_equal 'users', @user_group.permissions.pop.name
  end
end

