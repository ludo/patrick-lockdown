require 'helper'

class TestLockdownResource < MiniTest::Unit::TestCase

  def setup
    @resource = Lockdown::Resource.new(:users)
  end

  def test_initializer_sets_correct_state
    assert_equal @resource.name, 'users'
    assert_equal @resource.regex_pattern, "\/users(\/.*)?"
  end

  def test_except_sets_correct_regex_pattern
    @resource.except(:destroy)
    assert_equal @resource.regex_pattern, "\/users(?!\/(destroy))(\/.*)?"
  end

  def test_except_with_multiple_params_sets_correct_regex_pattern
    @resource.except(:index, :destroy)
    assert_equal @resource.regex_pattern, "\/users(?!\/(index|destroy))(\/.*)?"
  end

  def test_except_with_no_params_preserves_regex_pattern
    resource = Lockdown::Resource.new(:users)
    resource.except()
    assert_equal resource.regex_pattern, "\/users(\/.*)?"
  end

  def test_only_sets_correct_regex_pattern
    @resource.only(:index)
    assert_equal @resource.regex_pattern, "\/users\/(index)(\/)?"
  end

  def test_only_with_multiple_params_sets_correct_regex_pattern
    @resource.only(:show, :edit)
    assert_equal @resource.regex_pattern, "\/users\/(show|edit)(\/)?"
  end

  def test_only_with_no_params_preserves_regex_pattern
    resource = Lockdown::Resource.new(:users)
    resource.only()
    assert_equal resource.regex_pattern, "\/users(\/.*)?"
  end

end

