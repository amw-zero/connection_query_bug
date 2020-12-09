require 'hypothesis'
require 'test_helper'

class HypothesisTest < ActiveSupport::TestCase
  include Hypothesis
  include Hypothesis::Possibilities

  def stages
    any element_of([:inquiry, :lease_executed])
  end

  def deals(tenant:)
    built_as do
      existing_deal_count = any integers(min: 0, max: 3)
      existing_deal_count.times.map do
        Deal.create(tenant: tenant, stage: stages)
      end
    end
  end

  def connected_deals(tenant:)
    built_as do
      existing_deal_count = any integers(min: 0, max: 3)
      existing_deal_count.times.map do
        Deal.create(tenant: tenant, stage: :lease_executed)
      end
    end
  end

  def new_deals(tenant:)
    built_as do
      Deal.create(tenant: tenant, stage: stages)
    end
  end

  def tenants
    built_as do
      tenant_count = any integers(min: 2, max: 4), name: 'Tenant Count'
      tenant_count.times.map do |i|
        Tenant.create(name: "Tenant #{i}")
      end
    end
  end
  
  def test_deal_connection_query
    hypothesis do |test_case|
      DatabaseCleaner.clean

      some_tenants = any tenants, name: 'Tenants'

      connected_tenant = some_tenants.first
      deal_connection_deals = any connected_deals(tenant: connected_tenant), name: 'Connected Deals'
      other_deals = any deals(tenant: any(element_of(Tenant.all - [connected_tenant]))), name: 'Existing Deals'
      
      new_deal = any new_deals(tenant: connected_tenant), name: 'New Deal'

      if Connections.connection_exists?(new_deal)
        any_late_stage_deal = deal_connection_deals.any? { |d| d.stage.to_sym == :lease_executed }
        assert_equal true, any_late_stage_deal
      else
        assert_equal true, deal_connection_deals.all? { |d| d.stage.to_sym == :inquiry }
      end
    end    
  end
end