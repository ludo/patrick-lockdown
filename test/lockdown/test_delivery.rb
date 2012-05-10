require 'helper'

class Authorization
  extend Lockdown::Access
end

class TestLockdown < MiniTest::Unit::TestCase

  def setup
    Lockdown::Configuration.reset
  end

  def test_it_allows_uri_without_beginning_slash
    Authorization.permission :posts
    Authorization.public_access :posts

    assert_equal true, Lockdown::Delivery.allowed?('posts')
  end

  def test_it_allows_uri_without_ending_slash
    Authorization.permission :posts
    Authorization.public_access :posts

    assert_equal true, Lockdown::Delivery.allowed?('/posts')
  end

  def test_it_allows_uri_with_ending_slash
    Authorization.permission :posts
    Authorization.public_access :posts

    assert_equal true, Lockdown::Delivery.allowed?('/posts/')
  end

  def test_it_allows_uri_with_action
    Authorization.permission :posts
    Authorization.public_access :posts

    assert_equal true, Lockdown::Delivery.allowed?('/posts/new')
  end

  def test_it_allows_uri_access_to_only_show
    Authorization.permission :posts do
      resource :posts do
        only :show
      end
    end
    Authorization.public_access :posts

    assert_equal true, Lockdown::Delivery.allowed?('/posts/show')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/show')

    assert_equal false, Lockdown::Delivery.allowed?('/postsshow')

    assert_equal false, Lockdown::Delivery.allowed?('/posts/')

    assert_equal false, Lockdown::Delivery.allowed?('/posts/edit')
  end

  def test_it_allows_uri_access_to_all_except_show
    Authorization.permission :posts do
      resource :posts do
        except :show
      end
    end
    Authorization.public_access :posts

    assert_equal false, Lockdown::Delivery.allowed?('/posts/show')

    assert_equal false, Lockdown::Delivery.allowed?('/postsshow')

    assert_equal true, Lockdown::Delivery.allowed?('/posts')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/edit')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/edit/')
  end

  def test_it_allows_uri_access_to_create_as_post
    Authorization.permission :posts do
      resource :posts do
        only :new, :create
      end
    end
    Authorization.public_access :posts


    assert_equal false, Lockdown::Delivery.allowed?('/posts')

    assert_equal false, Lockdown::Delivery.allowed?('/posts/')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/new')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/new/')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/create')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/create/')

    assert_equal false, Lockdown::Delivery.allowed?('/posts/show')

    assert_equal false, Lockdown::Delivery.allowed?('/posts/show/')
  end

  def test_it_allows_uri_access_to_update_as_put
    Authorization.permission :posts do
      resource :posts do
        only :show, :edit, :update
      end
    end
    Authorization.public_access :posts


    assert_equal true, Lockdown::Delivery.allowed?('/posts/update')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/update/')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/edit')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/edit/')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/show')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/show/')

    assert_equal false, Lockdown::Delivery.allowed?('/posts/')
  end

  def test_it_denies_uri_access_to_destroy
    Authorization.permission :posts do
      resource :posts do
        except :destroy
      end
    end
    Authorization.public_access :posts

    assert_equal true, Lockdown::Delivery.allowed?('/posts/update')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/edit')

    assert_equal true, Lockdown::Delivery.allowed?('/posts/show')

    assert_equal false, Lockdown::Delivery.allowed?('/posts/destroy')
  end

  def test_it_denies_uri_access_to_new_create_and_destroy
    Authorization.permission :users do
      resource :users do
        except :new, :create, :destroy
      end
    end
    Authorization.public_access :users

    assert_equal true, Lockdown::Delivery.allowed?('/users/show')

    assert_equal false, Lockdown::Delivery.allowed?('/users/new')

    assert_equal false, Lockdown::Delivery.allowed?('/users/create')

    assert_equal false, Lockdown::Delivery.allowed?('/users/destroy')
  end

  def test_it_denies_index_access_to_resource_assigned_to_administrators
    Authorization.permission :register_account do
      resource :users do
        only :new, :create
      end
    end
    Authorization.public_access :register_account

    Authorization.permission :my_account do
      resource :users do
        only :show, :update
      end
    end
    Authorization.protected_access :my_account

    Authorization.permission 'users'
    Authorization.user_group 'Administrators', 'users'

    assert_equal true, Lockdown::Delivery.allowed?('/users/new')
    assert_equal true, Lockdown::Delivery.allowed?('/users/create')

    assert_equal false, Lockdown::Delivery.allowed?('/users/')

    assert_equal false, Lockdown::Delivery.allowed?('/users/', Lockdown::Configuration.authenticated_access)
    assert_equal false, Lockdown::Delivery.allowed?('/users', Lockdown::Configuration.authenticated_access)
  end

  def test_it_handles_namespaced_routes_correctly
    Authorization.permission :posts
    Authorization.permission :users
    Authorization.public_access :posts, :users

    Authorization.permission :protected_users do
      resource 'nested/users'
    end
    Authorization.protected_access :protected_users

    assert_equal true, Lockdown::Delivery.allowed?('/users')

    assert_equal false, Lockdown::Delivery.allowed?('/nested/users')

    assert_equal true, Lockdown::Delivery.allowed?('/users', Lockdown::Configuration.authenticated_access)
    assert_equal true, Lockdown::Delivery.allowed?('/nested/users', Lockdown::Configuration.authenticated_access)
  end

  def test_it_matches_exact_paths_only
    Authorization.permission :users
    Authorization.public_access :users

    Authorization.permission :users_that_should_be_protected
    Authorization.protected_access :users_that_should_be_protected

    assert_equal true, Lockdown::Delivery.allowed?('/users')

    assert_equal false, Lockdown::Delivery.allowed?('/users_that_should_be_protected')

    assert_equal true, Lockdown::Delivery.allowed?('/users', Lockdown::Configuration.authenticated_access)
    assert_equal true, Lockdown::Delivery.allowed?('/users_that_should_be_protected', Lockdown::Configuration.authenticated_access)
  end
end
