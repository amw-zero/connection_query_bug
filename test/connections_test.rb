require 'test_helper'

class ConnectionsTest < ActiveSupport::TestCase
  def test_something
    Tenant.create(name: 't1')
    assert_equal 1, 0
  end

  def test_something_else
    puts Tenant.count
  end
end