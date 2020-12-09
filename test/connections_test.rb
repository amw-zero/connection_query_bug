require 'test_helper'

class ConnectionsTest < ActiveSupport::TestCase
  def test_early_stage_deals
    tenant = Tenant.create(name: 't1')
    existing_deal = Deal.create(tenant: tenant, stage: :inquiry)
    new_deal = Deal.create(
      tenant: tenant, 
      stage: :inquiry
    )
    assert_equal(
      false, 
      Connections.connection_exists?(new_deal)
    )
  end

  def test_late_stage_deals
    tenant = Tenant.create(name: 't1')
    existing_deal = Deal.create(
      tenant: tenant, 
      stage: :lease_executed
    )
    new_deal = Deal.create(
      tenant: tenant, 
      stage: :lease_executed
    )
    assert_equal(
      true, 
      Connections.connection_exists?(new_deal)
    )
  end

  def test_existing_early_stage_deal
    tenant = Tenant.create(name: 't1')
    existing_deal = Deal.create(
      tenant: tenant, 
      stage: :inquiry
    )
    new_deal = Deal.create(
      tenant: tenant, 
      stage: :lease_executed
    )
    assert_equal(
      false, 
      Connections.connection_exists?(new_deal)
    )
  end

  # def test_new_late_stage_deal_does_not_count_as_connection
  #   tenant = Tenant.create(name: 't1')
  #   Deal.create(tenant: tenant, stage: :lease_executed)
  #   deal = Deal.create(tenant: tenant, stage: :lease_executed)

  #   assert_equal false, Connections.connection_exists?(deal)
  # end
end