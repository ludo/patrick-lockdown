require 'helper'

class H 
  include Lockdown::Helper
end

class TestLockdownHelper < MiniTest::Unit::TestCase

  def setup
    @h = H.new
  end

  def test_administrator_group_name
    assert_equal 'Administrators', @h.administrator_group_name
  end

  def test_user_groups_hbtm_reference
    assert_equal :user_groups, @h.user_groups_hbtm_reference
  end

  def test_user_group_id_reference
    assert_equal 'user_group_id', @h.user_group_id_reference
  end

  def user_hbtm_reference
    assert_equal :users, @h.users_hbtm_reference
  end

  def user_id_reference
    assert_equal 'user_id', @h.user_id_reference
  end
end

