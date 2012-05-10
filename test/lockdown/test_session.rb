require 'helper'

class Authorization
  extend Lockdown::Access
end

class S
  include Lockdown::Session

  attr_accessor :session_access_rights
end

class TestLockdownSession < MiniTest::Unit::TestCase

  def setup
    Lockdown::Configuration.reset
    @s = S.new
  end

  def test_access_in_perm
    Authorization.permission :posts
    Authorization.permission :users
    Authorization.public_access :posts

    @s.session_access_rights = Lockdown::Configuration.public_access

    assert_equal true , @s.send(:access_in_perm?, 'posts')
    assert_equal false , @s.send(:access_in_perm?, 'users')
  end
end

